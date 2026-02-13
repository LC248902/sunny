# On your Mac terminal — save as test_correct_order.py and run with: python test_correct_order.py
import json
from mlx_vlm import load, generate

model_path = "./quant-experiments/sunny-medgemma-mlx-4bit-gs32"

print(f"[INFO] Using model: {model_path}")
model, processor = load(model_path)
print(f"[INFO] Model loaded!")

# Manually construct prompt with image BEFORE text (matching training format)
prompt = "<bos><start_of_turn>user\n<start_of_image>sunscreen extract<end_of_turn>\n<start_of_turn>model\n"

print("=== PROMPT ===")
print(repr(prompt))
print("==============")

output = generate(
    model, processor, prompt,
    ["./data/sunscreen-test-1.jpeg"],
    max_tokens=512,
    temperature=0.7,
    top_p=0.95,
    repetition_penalty=1.2, 
    # repetition_context_size=256,
    verbose=True
)
print(output)
print()
print(f"[INFO] Output JSON:")
print(json.loads(output.text))