# On your Mac terminal — save as test_order.py and run with: python test_order.py
from mlx_vlm import load, generate
from mlx_vlm.prompt_utils import apply_chat_template
from mlx_vlm.utils import load_config

model_path = "./quant-experiments/sunny-medgemma-mlx-8bit-gs32"
model, processor = load(model_path)
config = load_config(model_path)

prompt = "sunscreen extract"
image = "./data/sunscreen-test-1.jpeg"

# Check what the formatted prompt looks like
formatted_prompt = apply_chat_template(
    processor, config, prompt, num_images=1
)
print("=== FORMATTED PROMPT ===")
print(repr(formatted_prompt))
print("========================")

# Generate
output = generate(
    model, processor, formatted_prompt,
    [image],
    max_tokens=512,
    temperature=1.0,
    verbose=True
)
print(output)