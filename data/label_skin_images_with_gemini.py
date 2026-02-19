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
API_KEY = os.getenv("GEMINI_API_KEY") 
IMAGE_FOLDER = "ISIC-2024/ISIC_2024_Permissive_Training_Input_1k_Sample"  # Update to your folder name
OUTPUT_JSON_PATH = "ISIC-2024-skin_tracking_descriptions-1k.json"
MODEL_ID = "gemini-3-flash-preview" # Optimized for speed and description accuracy

PROMPT_VLM_SKIN_DESCRIPTION = """
Role: You are a specialized morphological observer for a skin-tracking application. 
Task: Describe the skin lesion in the provided image using a structured, narrative format.

Guidelines:
1. No Diagnosis: Do not name conditions (e.g., avoid "melanoma" or "mole").
2. No Medical Advice: Do not provide safety assessments.
3. Language: Use Sentence Case. Ensure descriptions are readable and descriptive.
4. Objectivity: Describe only what is visually present.

Extraction Schema:
{
  "lesion_type": "Description of the type (e.g., A pigmented macule/flat).",
  "color": "Description of hues and pigment distribution.",
  "symmetry": "Description of the balance of shape and color.",
  "borders": "Description of the margins/edges.",
  "texture": "Description of the surface quality.",
  "summary": "A 1-2 sentence takeaway for the user to share with a doctor."
}

Formatting Rules:
- Return ONLY valid JSON.
- If a feature is not visible due to image quality, return "Undetermined due to image resolution or focus."
"""

# ==========================================
# PIPELINE LOGIC
# ==========================================
client = genai.Client(api_key=API_KEY)

def process_pipeline():
    image_extensions = (".png", ".jpg", ".jpeg", ".webp")
    
    # 1. Load existing results (Resume logic)
    existing_results = []
    done_paths = set()
    if os.path.exists(OUTPUT_JSON_PATH):
        try:
            with open(OUTPUT_JSON_PATH, "r") as f:
                existing_results = json.load(f)
                done_paths = {item["image_path"] for item in existing_results}
        except json.JSONDecodeError:
            print(f"⚠️ Warning: {OUTPUT_JSON_PATH} is corrupted.")

    # 2. Identify images
    all_image_paths = [
        str(Path(os.path.join(IMAGE_FOLDER, f)).resolve()) 
        for f in os.listdir(IMAGE_FOLDER) 
        if f.lower().endswith(image_extensions)
    ]
    
    to_do_paths = [p for p in all_image_paths if p not in done_paths]
    
    print("=" * 40)
    print(f"🔬 SKIN TRACKER VLM LABELLER")
    print("-" * 40)
    print(f"✅ Images Done:  {len(done_paths)}/{len(all_image_paths)}")
    print(f"⏳ Images To Do: {len(to_do_paths)}/{len(all_image_paths)}")
    print("=" * 40)

    if not to_do_paths:
        print("🎉 All images processed!")
        return

    results = existing_results 

    # 3. Iterative Labeling
    for path in tqdm(to_do_paths, desc="Describing", unit="img"):
        try:
            with open(path, "rb") as f:
                image_bytes = f.read()

            image_part = types.Part.from_bytes(data=image_bytes, mime_type='image/jpeg')
            
            start_time = time.time()
            
            response = client.models.generate_content(
                model=MODEL_ID,
                contents=[PROMPT_VLM_SKIN_DESCRIPTION, image_part],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    # Adjust safety for clinical/medical imagery
                    safety_settings=[
                        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
                    ])
            )
            
            latency = round(time.time() - start_time, 2)

            if not response or not response.text:
                output_json = {"error": "Empty response"}
            else:
                output_json = json.loads(response.text)

            record = {
                "image_path": path,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "analysis": output_json,
                "latency": f"{latency}s"
            }
            
            results.append(record)
            
            with open(OUTPUT_JSON_PATH, "w") as f:
                json.dump(results, f, indent=4)
                
        except Exception as e:
            tqdm.write(f"❌ Error: {os.path.basename(path)}: {str(e)}")
            time.sleep(1)

    print(f"\n✅ Finished! Analysis saved to: {OUTPUT_JSON_PATH}")

if __name__ == "__main__":
    if not API_KEY:
        print("❌ Error: GEMINI_API_KEY missing.")
    else:
        process_pipeline()