import os
import json
import time
from pathlib import Path
from tqdm import tqdm
from google import genai
from google.genai import types

# ==========================================
# CONFIGURATION
# ==========================================
API_KEY = os.getenv("GEMINI_API_KEY") # saved GEMINI_API_KEY to ~/.zshrc
IMAGE_FOLDER = "sunscreen-photos"
OUTPUT_JSON_PATH = "sunscreen_labels_output.json"
MODEL_ID = "gemini-3-flash-preview" 

PROMPT_VLM_SUNSCREEN = """
Role: You are a specialized dermatological data extraction agent. Your goal is to convert images of sunscreen packaging into structured JSON for a skin-health tracking app.

Task:
1. Identify Orientation: Determine if the image is "front", "back", or "other".
2. Extract Data: Capture specific fields based on the identified side. 
3. Classify Formula: Based on the ingredients, classify the 'formula_type' as "Mineral", "Chemical", or "Hybrid".
4. Tag Ingredients: For each active ingredient, label it as "Mineral" or "Chemical".
5. Normalize Units: Convert all ingredient concentrations to percentages (e.g., 50mg/g = 5.0%).

Extraction Schema:
{
  "side": "front" | "back" | "other",
  "formula_type": "Mineral" | "Chemical" | "Hybrid" | "Not visible",
  "data": {
    "brand": "string",
    "product_name": "string",
    "spf": "number",
    "spectrum": "boolean",
    "water_resistance": "number (minutes)",
    "regulatory_id": "string",
    "assumed_main_ingredient": "string",
    "active_ingredients": [
      {"name": "string", "percentage": "string", "category": "Mineral" | "Chemical"}
    ],
    "preservatives": ["string"],
    "claims": ["string"],
    "application_timer": "number (minutes)",
    "storage_limit": "number (celsius)",
    "warnings": "string"
  }
}

Formatting Rules:
- Return ONLY valid JSON.
- If a field is not visible or cannot be extracted, return the string "Not visible".
- For the 'side' field, if the image is neither clearly front nor back, return "other".
"""

# ==========================================
# PIPELINE LOGIC
# ==========================================
client = genai.Client(api_key=API_KEY)

def process_pipeline():
    image_extensions = (".png", ".jpg", ".jpeg", ".webp")
    
    # 1. Load existing results to handle "Resume" logic
    existing_results = []
    done_paths = set()
    if os.path.exists(OUTPUT_JSON_PATH):
        try:
            with open(OUTPUT_JSON_PATH, "r") as f:
                existing_results = json.load(f)
                done_paths = {item["image_path"] for item in existing_results}
        except json.JSONDecodeError:
            print(f"⚠️ Warning: {OUTPUT_JSON_PATH} is corrupted. Starting fresh.")

    # 2. Identify all images in folder
    all_image_paths = [
        str(Path(os.path.join(IMAGE_FOLDER, f)).resolve()) 
        for f in os.listdir(IMAGE_FOLDER) 
        if f.lower().endswith(image_extensions)
    ]
    
    # 3. Filter for images not yet done
    to_do_paths = [p for p in all_image_paths if p not in done_paths]
    
    # 4. Display Stats
    num_total = len(all_image_paths)
    num_done = len(done_paths)
    num_to_do = len(to_do_paths)
    
    print("=" * 40)
    print(f"☀️  SUNNY VLM LABELLER STATS")
    print("-" * 40)
    print(f"✅ Images Done:  {num_done}/{num_total}")
    print(f"⏳ Images To Do: {num_to_do}/{num_total}")
    print(f"📁 Folder:       {IMAGE_FOLDER}")
    print("=" * 40)

    if num_to_do == 0:
        print("🎉 Everything is already labeled!")
        return

    results = existing_results # Append mode

    # 5. Iterative Labeling
    for path in tqdm(to_do_paths, desc="Labeling", unit="img"):
        try:
            with open(path, "rb") as f:
                image_bytes = f.read()

            image_part = types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg')
            
            start_time = time.time()
            
            response = client.models.generate_content(
                model=MODEL_ID,
                contents=[PROMPT_VLM_SUNSCREEN, image_part],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    safety_settings=[
                        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
                    ])
            )
            
            latency = round(time.time() - start_time, 2)

            # Safety check for empty model responses
            if not response or not response.text:
                tqdm.write(f"⚠️ Empty response for {os.path.basename(path)}")
                output_json = {"error": "Empty response from API"}
            else:
                output_json = json.loads(response.text)

            record = {
                "image_path": path,
                "input": PROMPT_VLM_SUNSCREEN.strip(),
                "output": output_json,
                "time_taken": f"{latency}s"
            }
            
            results.append(record)
            
            # Save incrementally
            with open(OUTPUT_JSON_PATH, "w") as f:
                json.dump(results, f, indent=4)
                
        except Exception as e:
            tqdm.write(f"❌ Error processing {os.path.basename(path)}: {str(e)}")
            # Optional: Add a brief sleep to handle temporary network issues
            time.sleep(1)

    print(f"\n✅ All set! Results updated in: {OUTPUT_JSON_PATH}")

if __name__ == "__main__":
    if not API_KEY:
        print("❌ Error: GEMINI_API_KEY not found in environment. Check your .env or ~/.zshrc.")
    else:
        process_pipeline()