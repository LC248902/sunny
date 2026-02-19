---
base_model: google/medgemma-1.5-4b-it
library_name: transformers
model_name: medgemma-1.5-4b-sunny-skin-finetune
tags:
- generated_from_trainer
- trl
- sft
licence: license
license: gemma
datasets:
- mrdbourke/sunny-skin-and-sunscreen-extract-1k
pipeline_tag: image-text-to-text
---

# Model Card for medgemma-1.5-4b-sunny-skin-finetune

This model is a fine-tuned version of [google/medgemma-1.5-4b-it](https://huggingface.co/google/medgemma-1.5-4b-it) on the [mrdbourke/sunny-skin-and-sunscreen-extract-1k](https://huggingface.co/datasets/mrdbourke/sunny-skin-and-sunscreen-extract-1k) dataset.

It has been trained using [TRL](https://github.com/huggingface/trl).

## Resources

* **GitHub repo:** [mrdbourke/sunny](https://github.com/mrdbourke/sunny/)
* **Fine-tuning notebook:** [sunny_MedGemma_fine_tuning.ipynb](https://github.com/mrdbourke/sunny/blob/main/sunny_MedGemma_fine_tuning.ipynb)
* **Dataset used:** [mrdbourke/sunny-skin-and-sunscreen-extract-1k](https://huggingface.co/datasets/mrdbourke/sunny-skin-and-sunscreen-extract-1k)

## Quick start

```python
from transformers import pipeline
from datasets import load_dataset
import torch

# Load the model
pipe = pipeline(
    "image-text-to-text",
    model="mrdbourke/sunny-medgemma-1.5-4b-finetune",
    dtype=torch.bfloat16,
    device="cuda",
)

# Load a sample from the dataset
dataset = load_dataset("mrdbourke/sunny-skin-and-sunscreen-extract-1k")
sample = dataset["test"][0]

messages = [
    {
        "role": "user",
        "content": [
            {"type": "image", "image": sample["image"]},
            {"type": "text", "text": sample["input_prompt"]},
        ],
    }
]

output = pipe(text=messages, max_new_tokens=2000)
print(output[0]["generated_text"][-1]["content"])
```

## Training procedure

This model was trained with SFT.

### Framework versions

- TRL: 0.28.0
- Transformers: 5.2.0
- Pytorch: 2.9.0+cu128
- Datasets: 4.5.0
- Tokenizers: 0.22.2

## Citations

Cite TRL as:

```bibtex
@software{vonwerra2020trl,
  title   = {{TRL: Transformers Reinforcement Learning}},
  author  = {von Werra, Leandro and Belkada, Younes and Tunstall, Lewis and Beeching, Edward and Thrush, Tristan and Lambert, Nathan and Huang, Shengyi and Rasul, Kashif and Gallouédec, Quentin},
  license = {Apache-2.0},
  url     = {https://github.com/huggingface/trl},
  year    = {2020}
}
```