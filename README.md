# Sunny - Skin Tracking App

**Goal:** Enter [MedGemma Impact Challenge Kaggle competition](https://www.kaggle.com/competitions/med-gemma-impact-challenge) with Sunny, an app designed to use MedGemma-1.5 to help with skin tracking for possible prevention of skin cancer (prevention is the best cure).

## Overview

Sunny's goal: Turn personal skin tracking from a vague intentional to an actionable habit.

Rather than create a pure diagnostic play (research is not strong here from smartphone cameras), Sunny aims to help people develop a tracking habit.

In essence our pitch is as much psychological as it is technological.

## App Layout

There will be three tabs: Track, Review, Map.

Track allows someone to go through a step-by-step body scan where people can take photos and log them to the phone. Each photo is tied to a specific body part for easy referencing later.

Review allows someone to review the photos they've taken in the past and optionally add an updated photo (e.g. a more recent photo to an existing log) as well as export a report of all tracked items (this can be shared with a dermatologist).

Map shows a map overview of dermatologists nearby for easy contact and directional information.

## MedGemma Integration

MedGemma integrates as a writer for generating descriptions of images. These could be reviewed by a patient or dermatologist for further inspection.

Crucially, MedGemma is not providing a diagnosis, more so acting as an optional informed helper.

Extension: MedASR could later be integrated to allow voice-to-text notes for tracking or report discussing steps. For example, MedASR could transcribe a discussion between a patient and a dermatologist about their current review (the Review tab could have a voice recording feature which saves audio and attaches it to a particular review).

## Video ideas

There is a required 3 minute video to be submitted alongside the code and writeup materials.

For the video, my idea so far is: 

* Minute 1 - Introduction to the problem - this could be interviewing strangers with questions related to skin cancer to frame the problem
* Minute 2 - Discussing current landscape with healthcare professional 
* Minute 3 - Benefits and features of Sunny and how it addresses the problem and is a step in the right direction

### TK - Problem

### TK - Science

### TK - Gap

### TK - Solution

## Next

* IN PROGRESS: Upgrade the workflow of MedGemma running on iOS, can the app design be cleaner? 
    * Going to fine-tune MedGemma for our specific use case to see if this helps, the base model doesn't quite do what we'd like, prompting is okay but slows down inference quite a lot on device.
* Add examples of before and after of fine-tuning the model to see what it looks like 
* ✅ Read Australia's national skin cancer report card - https://www.dermcoll.edu.au/wp-content/uploads/2025/11/2025-REPORT_SKIN-CANCER-SCORECARD.pdf 
    * Done - many relavant points to our cause, especially costs, pros of early detection and a future avenue for ongoing support for patients who have been diagnosed with skin cancer but aren't sure what to do next, this seemed to be one of the biggest gaps in the report (ongoing support for life after diagnosis is minimal)
* ✅ Investigate the SLICE-3D dataset and see if this can be integrated into what we're making - https://challenge2024.isic-archive.com/
    * Done - using 1000 of these (they are quite low quality) for fine-tuning MedGemma 
* ✅ Contact another expert to get their advice on skin cancer + prevention + new technologies entering the field and how they're shaping dermatology.
    * Done - reached out to 3x experts/doctors so far but have yet to hear back, if this doesn't happen we may benchmark it and try another route 

## Log

* **13 Feb 2026** - Running into issues with quantization, it seems to make the model quite brittle when we do a naive quantization (e.g. "affine", this is the default in `mlx_vlm`). 4-bit-gs32 (group size 32) doesn't work as well as 8-bit-gs32 but is a much smaller model. This lower size is required for effective on-device deployment. The build out of learned quantization methods doesn't seem as much for `mlx_vlm` as it is `mlx_lm`, see [`LEARNED_QUANTS.md`](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md) for more.
    * The model works well in float16 but starts to get into an infinite loop of generation when in 4-bit. This is fine balance between performance and size. 
    * **Important:** Prompt order matters a lot too. The model was fine-tuned with <image><text> -> <text>. So this means when an image gets used, it should go *before* the text. If the <image> is placed after the text, underdesired generation outcomes can and will occur.
    * Trying an experiment to separate the LM from the Vision Model as `mlx_lm` has better support for learned quantization. Will try [`mlx_lm.dynamic_quant`](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md#dynamic-quantization) on *only* the LM weights and then merge those back with the vision model weights.
        * Starting with `mlx_lm.dynamic_quant`, then will move onto [`mlx.dwq`](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md#dwq) (distilled weight quantization) if it doesn't work...
    * Quantization with `mlx_lm.dynamic_quant` took a while (Mac Mini M4 Pro, 64GB RAM):

```
(ai) daniel@Daniels-Mac-mini quant-experiments % mlx_lm.dynamic_quant \
    --model ./medgemma-language-only \
    --mlx-path ./medgemma-lm-dynquant \
    --target-bpw 4.5 \
    --low-bits 4 \
    --high-bits 5
Estimating sensitivities: 56it [1:19:25, 85.09s/it]                                                                                             
[INFO] Quantized model with 4.502 bits per weight.
Peak memory used: 58.109GB
```

    * There is a paper too which discusses using different quantization strategies for the different modalities of the model (see: https://openaccess.thecvf.com/content/CVPR2025/papers/Li_MBQ_Modality-Balanced_Quantization_for_Large_Vision-Language_Models_CVPR_2025_paper.pdf), for example, vision models may be more negatively influenced by quantization than text models and vice versa.
    * Some good settings for the 4-bit-gs32 (this is with the default settings (`"affine"` or RTN - Round To Nearest quantization)) model seem to be: 

```
output = generate(
    model, processor, prompt,
    ["./data/sunscreen-test-1.jpeg"],
    max_tokens=512,
    temperature=0.7,
    top_p=0.95,
    repetition_penalty=1.2, 
    # repetition_context_size=256, # not sure of how much this seems to influence our output
    verbose=True
)
```

* **12 Feb 2026** - Going to fine-tune MedGemma-1.5 to be able to extract details from sunscreen packaging as well as extract details from dermatology photos. This will better align the model with our app's use cases.
    * Dataset to create: ~100 sunscreen photos with front and back extractions + ~1000 skin images with descriptions - these will be labelled with `gemini-3-flash-preview` and then distilled into MedGemma (hopefully this works)
        * Skin images come from [ISIC-2024 permissive license images](https://challenge2024.isic-archive.com/) and are a combined sample of: all malignant samples (294), all ideterminate samples (100), random benign samples to make it up to 1000 (606)
        * **Note:** Many of the images are quite low resolution... so might be hard to get a decent extraction from them. This may not translate well to on-device photos. Regardless, we will try to fine-tune and deploy a model! [Genchi genbutsu](https://en.wikipedia.org/wiki/Genchi_Genbutsu): Always test in the actual use case!
    * Going to save the dataset to Hugging Face with a simple format of "skin extract" + image -> skin output or "sunscreen extract" + image -> sunscreen output
        * I'll then fine-tune MedGemma-1.5 to reproduce these outputs and we'll put them in the app 
        * Dataset created! See: https://huggingface.co/datasets/mrdbourke/sunny-skin-and-sunscreen-extract-1k 
    * Started fine-tuning MedGemma-1.5 in Google Colab (using A100 GPU with 80GB of RAM, following the practice of freeze vision tower -> fine-tune LLM part)
        * Fine-tuning done! See: https://huggingface.co/mrdbourke/sunny-medgemma-1.5-4b-finetune 
        * **Note:** Fine-tuned on ~1100 samples for 3 epochs, vision backbone was frozen and the LLM was fully tuned. Could potentially look into a LORA in the future. See mlx_vlm's [LORA.md](https://github.com/Blaizzy/mlx-vlm/blob/main/mlx_vlm/LORA.MD) for more.
        * Now to convert it to MLX (so we can run it on device), see: https://huggingface.co/mrdbourke/sunny-medgemma-1.5-4b-finetune-mlx-4bit 
            * **Note:** Make sure to use `mlx_vlm convert` to ensure the vision model gets converted as well as the text model.
        * Converted to MLX 4-bit, however noticing some degradation well deploying to on-device. The float16 model works well. 
        * Going to investigate generation settings as well as if we can get learned quantization working.
    * Haven't heard back from any emails to dermatologists or doctors, this is okay and understandable, might just hit the streets and ask strangers for input:
        * "What do you think is the most common cancer in Australia?"
        * "Which cancer do you think costs the most to treat in Australia?"
        * "What percentage of skin cancers are discoverd by the patient themselves or their partner?"
        * "When was your last skin check?" -> "In an ideal world, how often would you check?" 
        * "What's your barrier to entry for skin checking?"

* **11 Feb 2026** - Booked a skin check appointment at a local skin cancer clinic to get literal "skin the game".
    * Called a practice to see if any skin cancer doctors might be available to talk to. Will follow up with email.
    * Collected 100x photos of sunscreens (front and back) for potential fine-tuning of MedGemma to extract details from sunscreens (current base version of MedGemma does a good job of avoiding images which aren't specific health-related).
    * Began reading through Australia's skin cancer report card for 2025 and taking notes to weave it into the overall narative of Sunny.
    * Got initial designs for "Spot" the Sunny mascot (a cute Quokka!!).
    * Emailed a skin cancer centre manager for request to speak with a doctor about our project.

* **10 Feb 2026** - Called UQ dermatology office and Prof Soyer is currently away, however, he may reply to emails whilst on holidays. They said not many other people there to talk to. Will try contacting Cancer Council next.
    * Emailed another researcher based at UQ for potential interview questioning.
    * Got [MedASR](https://huggingface.co/google/medasr) (Medical Automatic Speech Recognition) running on device. This is quite a fast model (about 77-100x real-time factor on-device). See notes below.

Turns out MedASR is trained on medical-specific terminology so it's more of a "Doctor dictates medical terms" ASR model than a generalist speech recognition model. So rather than record a general conversation between two people, it's focused on the following type of text.

Spoken input:

```
Exam type targeted skin exam period Indication 42 year old male comma suspicious mole period Findings colon Right upper back comma 6 millimeter asymmetric macule with irregular borders period Procedure colon Shave biopsy performed after consent period New paragraph Impression colon Atypical pigmented lesion comma right upper back period Plan colon Awaiting pathology period Follow up 2 weeks period
```

Transcribed output with MedASR:

```
[EXAM TYPE] Targeted skin exam . [INDICATION] 42-year-old male , suspicious mole . [FINDINGS] : Right upper back , 6 mm asymmetric macule with reregular borders . [PROCEDURE] : Shave biopsy performed under consent . {new paragraph} [IMPRESSION] : Atypical pigmented lesion , right upper back . [PLAN] : Awaiting paphology . Followup two weeks .</s>
```

* **9 Feb 2026** - Reading [*The SLICE-3D dataset: 400,000 skin lesion image crops extracted from 3D TBP for skin cancer detection*](https://www.nature.com/articles/s41597-024-03743-w) paper for insight into how skin images might be leveraged for improving MedGemma.
    * Got MedGemma running on device! Time to make it clean and build an interface around it.
    * Emailed a local skin cancer expert for advice + potential interview... turns out this person is overseas until February 23 2026... a bit too close to the deadline. 
        * All good, going to try someone else.