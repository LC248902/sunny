# Sunny - MedGemma Impact Kaggle Competition Writeup

## Project Name

Sunny - an iOS app powered by MedGemma-1.5 to help people track their skin health over time.

![](./images/header-sunny-overview.png)

## Team

* [Daniel Bourke](https://www.mrdbourke.com/) (@mrdbourke) — Machine Learning Engineer, handled fine-tuning of MedGemma, dataset creation and conversion steps to enable the model to run on-device.
* Joshua Bourke — iOS Engineer, handled app creation and model integration to run on-device.

## Resources

| Resource | Description | Link |
|----------|-------------|------|
| TK - Sunny iOS TestFlight App | iOS app showcasing the use of the Sunny-MedGemma model running natively for helping extract information from skin and sunscreen photos. | TK |
| TK - Writeup | Full writeup of project including problem definition, impact discussion and solution walkthrough. | TK |
| TK - Video | Video overview of the Sunny project. | TK |
| Code | Full code and resources on GitHub. | [Link](https://github.com/mrdbourke/sunny) | 
| Sunny MedGemma Fine-Tuning Notebook | Notebook to fine-tune MedGemma to extract structured data from skin and sunscreen images. **Note:** Best viewed in Google Colab as GitHub rendering fails to show images. | [Link](https://github.com/mrdbourke/sunny/blob/main/sunny_MedGemma_fine_tuning.ipynb) |
| Sunny Dataset | Dataset for fine-tuning MedGemma for skin and sunscreen extraction. | [Link](https://huggingface.co/datasets/mrdbourke/sunny-skin-and-sunscreen-extract-1k) |
| Sunny-MedGemma-PyTorch | Fine-tuned MedGemma specifically for Sunny's use case of extracting data from skin and sunscreen images. | [Link](https://huggingface.co/mrdbourke/sunny-medgemma-1.5-4b-finetune) |
| Sunny-MedGemma-MLX | Fine-tuned MedGemma converted to MLX for deployment on iOS devices. | [Link](https://huggingface.co/mrdbourke/sunny-medgemma-1.5-4b-finetune-mlx-4bit) |

## Disclaimers 

* Sunny is not a diagnostic tool, rather a utility for people to track their own skin and discuss findings with their doctor. We agree with the Australian Cancer Council: 

> *Cancer Council Australia does not recommend the use of smartphone applications by consumers to self-diagnose skin cancer. Source: [cancer.org.au](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/early-detection)*

* Sunny is targeted at *all* potential skin cancers, however the literature often reports on melanoma and keratinocyte cancers separately.

## Problem Domain

Australia is known for its beaches and vast plains. Some poets even refer to it as the sunburnt country [^1].

However, this sunburn comes at a cost.

Australia has the highest rate of skin cancer in the world [^2]. 

In 2023, combined deaths from melanoma and keratinocyte cancers totalled an estimated ~2,105 [^3], meaning around 2,000 Australians die from skin cancer each year [^4], more than the number of people who die in Australian transport accidents [^5]. 

A tragic outcome of the sun Australians love so much.

In 2023–24, skin cancer collectively (melanoma and non-melanoma/keratinocyte cancers) cost the Australian healthcare system approximately $2.47 billion.

![A stacked horizontal bar chart from the AIHW showing Australia's total health expenditure by cancer type. The bars are segmented by expenditure area: Hospitals, Primary health care, and Referred medical services. Green arrows and text overlays have been added to the graphic to highlight skin cancer costs specifically. An arrow points to the 'Non-melanoma skin cancer' bar—which is the third highest cost overall—with the text '$1,872M'. Another arrow points further down to the 'Melanoma of the skin' bar with the text '$596M'. Text between these two highlighted figures reads 'Total = $2.47B'.](./images/00-cost-of-skin-cancer-in-australia-2023-2024.png)

*Australian expenditure on Burden of Disease conditions by area of expenditure and state, 2023–24.*
*Source: Figure 11 via [aihw.gov.au](https://www.aihw.gov.au/reports/health-welfare-expenditure/health-system-spending-disease-injury-aus-2023-24/contents/spending-on-disease-by-abod-conditions)*

With melanoma treatment accounting for $596 million [^6] and keratinocyte skin cancers costing $1.87 billion [^7]. Skin cancer is the most expensive cancer to treat in Australia, more than lung, breast, and bowel cancer [^7].

When it comes to treatments, the numbers are clear.

If discovered early, melanoma can often be treated in the community (e.g., via GP/skin clinic excision) for a mean first-year cost of AU$644 for melanoma in situ (Stage 0) [^8], rising to around AU$1,681/year for Stage I/II in Australian cost modelling [^11] and even further for later stages.

However, if treatment has to move to hospital because melanoma is at a later stage, costs quickly increase, reaching AU$37,729/year for Stage III (resectable) [^11] and around AU$100,725 in the first year for unresectable Stage III/IV disease in the latest Australian estimates [^8]. Australian modelling also reported three-year costs of AU$187,720 for unresectable Stage III/IV [^11].

| Melanoma stage | Treatment setting (typical) | Cost basis | Cost (AU$) | Multiplier vs Stage 0 (AU$644) | Source |
|---|---|---:|---:|---:|---|
| Stage 0 (melanoma in situ) | Community (often GP/skin clinic excision) | Mean first-year cost per patient | 644 | 1.0× | [^8] |
| Stage I/II | Mostly community + specialist follow-up | Mean annual cost per patient | 1,681 | 2.6× | [^11] |
| Stage III (resectable) | Hospital + surgery ± adjuvant care | Mean annual cost per patient | 37,729 | 58.6× | [^11] |
| Stage III/IV (unresectable) | Hospital + systemic therapies | Mean first-year cost per patient | 100,725 | 156.4× | [^8] |
| Stage III/IV (unresectable) | Hospital + systemic therapies | 3-year total cost per patient | 187,720 | 291.5× | [^11] |

In terms of mortality, a skin cancer discovered and treated at Stage I has a ~99–100% five-year survival rate [^9].

Whereas five-year survival rate drops to ~61% at Stage III (depending on resectability) and just ~26% if a melanoma reaches Stage IV [^9].

Researchers and health professionals agree: prevention is the best cure. 

And Australia invests in marketing campaigns discussing sun safety techniques through the SunSmart program which has been running since 1988 [^10]. Research has found that every $1 invested in SunSmart generates a $2.30 net saving [^10].

But even with all of this, there is currently no national screening program [^12]. The current recommended approach is to "perform self-skin examinations" and "visit a skin doctor when you notice a change" [^13].

So far this approach has performed reasonably well, with ~44% of melanomas discovered by patients themselves or by a partner [^14], [^15]. 

But we think this could be better.

That's where Sunny comes in.

Sunny fills the gap of the lack of a national screening program at a minimal cost.

Our primary user is an Australian adult aged 30–70 who is aware of skin cancer risk and believes they monitor their skin, but does not regularly perform a structured whole-body examination. The person in the gap between the 66% who say they regularly check their skin for changes [^16] and the ~22% who actually received a whole-body skin check in the past 12 months [^17].

Sunny transforms a vague "perform self-skin examinations" recommendation into a structured and repeatable full-body self-skin examination habit with trackable progress.

TK image 01 - sunny workflow in app (what does using it)

## Impact Potential

Our vision is for Sunny to become the national standard for self-skin-examination (SSE). 

A central place where people can keep track of their skin and potential changes over time. 

No more vague memories of what a skin spot used to look like, Sunny provides a structured way for thorough self-skin-examination and tracking over time.

In a country where 44% of melanomas are first noticed by the patient themselves [^14], [^15], making self-examination easier and more consistent is one of the highest-impact interventions available. 

Research suggests SSE may reduce melanoma mortality by as much as 63% [^18], primarily by catching skin cancers earlier when the 5-year survival rate is ~99-100% (Stage I) versus just ~26% (Stage IV)

And when treatment costs AU$644/year per patient for early stage treatment compared to AU$100,725+ for advanced disease [^8], early detection comes with a large cost saving opportunity.

In light of this, our goals are:

- **Increase the number of Australians who perform a whole-body self-skin examination at least once per year:** from ~26% to **50%** [^19].
- **Increase number of skin cancer cases treated at early stage (Stage I) by 20%:** i.e., 20% fewer cases progressing to late stage (Stage III/IV).

If successful, this will see*:

- **~$11 million in healthcare cost savings per year** — driven by the 60× cost gap between early and late-stage treatment for melanoma.
    - Based on moving 175 cases from late (Stage III/IV,  $37,729 to $100,725/year) to early (Stage I, $1,681/year).
- **~83 Australian lives saved per year** — roughly 1-2 lives saved every week.
    - Assumed on late stage cases taking on the early stage survival profile. 

![A dark-themed infographic illustrating the impact of "Sunny". A legend shows white bars represent "Before Sunny" and orange bars represent "After Sunny". Two bar charts show: "Percentage of Australian's performing yearly SSE's" increases from 26% to 50% (marked with a green 2x arrow), and "Percentage of skin cancer cases treated at Stage I or earlier" increases from 78% to 93.6% (marked with a green +20% arrow). On the right, under "Impact," it states $11M saved per year and 83 lives saved per year.](images/02-sunny-impact-numbers.png)

*Before and after Sunny impact. Sunny's goal is to increase the number of Australian's performing yearly self-skin-examinations (SSE's) and in turn increase the liklihood of catching skin cancer early, resulting in earlier more cost effective treatments and better mortality outcomes.*

\****Note:** These numbers are estimates and would require further research to be backed up correctly. While Sunny is compatiable with any skin cancer, these are focused on melanoma where there is more data available. Numbers would likely increase with keratinocyte cancer data.*

## Overall Solution 

Sunny is an iOS application which runs a fine-tuned version of MedGemma-1.5-4B called Sunny-MedGemma on device via Apple’s MLX framework.

Sunny gives the user a structured way to perform a full body examination as well as allows them to review and update previously logged skin photographs.

TK image 03 - Sunny app workflow: Front page -> add scan -> body part -> photo -> model -> output save -> report export with metadata 

Due to the sensitive nature of skin photographs, using an API-based model solution was out of the question.

All data within the Sunny app is passcode protected and never leaves the user’s device unless explicitly shared with a doctor. 

When a user takes a photo of their skin, Sunny-MedGemma generates a structured description in a similar format to what a dermatologist would report on.

This inference happens completely on-device.

MedGemma-1.5-4B fits as the perfect base model for this workflow for a number of reasons:

* **Privacy, free inference and small enough to run on-device:** MedGemma-1.5-4B brings AI to where people are, their own devices. Users of Sunny can be confident no data will ever leave their device for inference or storage. Because Sunny-MedGemma runs on device, this also means inference cost is next to zero, meaning Sunny could be deployed to millions of people without significantly increasing costs.
* **Trained a vast number of medical images:** The [data card for MedGemma-1.5-4B](https://huggingface.co/google/medgemma-1.5-4b-it#data-ownership-and-documentation) lists a large amount of dermatology-related datasets used in training. This means the model already has a good representation of the type of skin images seen in the Sunny workflow. Other models, such as Gemma-3n, have good broad vision and language capabilities and could potentially be fine-tuned for our workflow, however, this would likely take far more effort. Hence, MedGemma’s medical focus wins out over other general models.
* **Better structured data generation:** The [benchmarks show](https://huggingface.co/google/medgemma-1.5-4b-it#document-understanding-evaluations) MedGemma-1.5-4B is much better at structured data outputs than the previous generation (this is important for crafting reliable and readable reports).

## Technical Details

We fine-tune MedGemma-1.5 on a [custom dataset](https://huggingface.co/datasets/mrdbourke/sunny-skin-and-sunscreen-extract-1k) for our workflow.

Specifically, we collect 1000 images of skin and structured text-based descriptions in a similar style to what dermatologists would record during skin examinations.

We also collect 100 images of the front and back of sunscreen bottles for structured sunscreen data extraction (though our app is mainly focused on skin photos as sunscreen extraction performance requires improvement).

Since MedGemma-1.5 already has a significant latent representation of skin and text-based images, the fine-tuning is specifically to get it to extract structured data with a much smaller input prompt.

For example, we use the `“skin extract”` (token count = 3) prompt rather than a much larger structured data extraction prompt (token count = 248).

!['A diagram illustrating how the MedGemma Tokenizer converts different prompt lengths into token arrays. On the left, a brief variable SKIN_EXTRACT_PROMPT_SHORT containing just the text "skin extract" passes through the tokenizer, resulting in an array of three numbers and a "Short prompt token count: 3". On the right, SKIN_EXTRACT_PROMPT_LONG contains a highly detailed multi-line instruction set including a role, task, guidelines, and a JSON extraction schema for analyzing skin lesions. Passing this through the tokenizer yields a much larger array of numbers and a "Long prompt token count: 248"'](./images/04-short-vs-long-token-inputs.png)

*Comparison of token counts for short versus long(er) input prompts to perform the same goal task. Long prompt token IDs shortened for brevity.*

Why a small input prompt?

Because when deploying a model to an edge device such as a mobile phone with limited memory, every token counts.

We are not necessarily introducing new knowledge to the model, rather shaping its outputs.

Following the [SmolDocling paper](https://arxiv.org/abs/2503.11576), we freeze the vision tower and fully fine-tune the multimodal projector as well as language model.

We fine-tune the model using [Hugging Face’s TRL](https://github.com/huggingface/trl) in a supervised fine-tuning manner on a 80GB A100 via Google Colab for 3 epochs which takes around 40-50 minutes.

Please see the linked resources above for more.

### Before and after fine-tuning

Before fine-tuning, the base MedGemma-1.5 model is able to extract skin and sunscreen related details.

However, when inputted with our shorter prompts such as “sunscreen extract” and “skin extract”, the generated outputs are not in a structured manner that we’d like for our in-app workflow.

We also found the quantized MLX version of the base model could not reliably adhere to a longer prompt (see `prompts/skin_extract_long.txt`) as well as the Transformers/PyTorch version of the base model. Fine-tuning the base model made the structured generations much more reliable when in MLX format.

!["A side-by-side comparison of three mobile app screens demonstrating different model outputs for a skin lesion analysis. The left screen, labeled 'Base MLX model + "skin extract" prompt', points to a red-dashed box highlighting 'Excessive disclaimer output'. The middle screen, 'Base MLX model + long skin extract prompt', highlights 'Unreliable JSON output' showing markdown formatting errors. The right screen, 'Fine-tuned MLX model + "skin extract" prompt', uses green-dashed boxes to highlight that it successfully 'Adheres to structure' by producing clean JSON, and achieves the 'Shortest total time', pointing to a total processing time of 13.47 seconds compared to the longer 26.39s and 28.44s times on the other screens."](./images/05-demo-app-generation-comparisons.png)

*Comparison of before and after fine-tuning with various prompts. Left: The base model tends to generate excess disclaimers. We can provide these in the UI of the app so these are fine-tuned out. Middle: The base model with a longer prompt unreliably generates JSON outputs. Right: The fine-tuned Sunny-MedGemma model is able to reliably generate structured outputs in our desired format.*

The base MedGemma-1.5 model also consistently outputs disclaimers about not being a diagnostic tool. While these are helpful reminders, we find them unnecessary in our app workflow as we can place disclaimers and warnings like these in the onboarding flow rather than generating them every time. To save on generated tokens, we fine-tune without these disclaimers.

### Conversion to MLX

Once our Sunny-MedGemma model was fine-tuned, we [uploaded it to the Hugging Face Hub](https://huggingface.co/mrdbourke/sunny-medgemma-1.5-4b-finetune).

Since this was in Transformers/PyTorch format and in `torch.bfloat16` datatype, it was incompatible with running on device. 

So we converted the model to MLX format using [`mlx-vlm`](https://github.com/Blaizzy/mlx-vlm) and lowered it to 4bit with rounding to nearest (RTN) quantization.

This quantization reduced the model’s footprint from 8.6GB (PyTorch format) to 3.4GB (MLX format), a much more accessible size for an edge device without degrading quality too much.

### Deployment to iOS

We download the model and tokeniser artifacts using [Hugging Face’s Swift Transformers](https://github.com/huggingface/swift-transformers).

Inference is performed using [`mlx-swift-lm`](https://github.com/ml-explore/mlx-swift-lm). 

Based on user intent (e.g. tapping through the app) we pre-load the model so it is ready to perform inference as soon as someone takes a photo.

Inference for a skin extraction takes 5-6s TFTT (time to first token) and about 10-13s token on an iPhone 17 Pro and depending on the detail in a sunscreen photo extraction takes 10-20s on an iPhone 17 Pro.

Future work would involve decreasing these inference times through better on-device optimizations such as leveraging CoreML for the vision encoder (similar to [Apple’s FastVLM](https://github.com/apple/ml-fastvlm)).

Our application is available to try out via TestFlight (TK - link to TestFlight) and all of our code is available in the `sunny` GitHub repo.

## Limitations and Future Work

* **Quantization slightly degrades model performance.** The default quantization method in `mlx-vlm` is a round to nearest (RTN) technique. We find for longer generations on device such as extracting many details from sunscreen bottles, the model begins to create an endless loop. This is not the case for the same images when running in `torch.bfloat16`. Future works would likely explore learned quantization methods such as those mentioned in [`LEARNED_QUANTS.md`](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md) in the [`mlx-lm`](https://github.com/ml-explore/mlx-lm) repo.
* **Bringing Sunny to Android.** Right now, Sunny is iOS only (this is where our team's skillset is). Future work would focus on expanding it to Android as well. On-device deployment for Android could use a similar workflow to [Google's AI Edge Gallery](https://github.com/google-ai-edge/gallery) as well as leverage [LiteRT-LM](https://github.com/google-ai-edge/LiteRT-LM) for deployment.
* **Speeding up the vision encoder.** To improve prefill speeds and TTFT (time to first token), we’d like to explore using a different vision encoder such as [MobileNetV5](https://huggingface.co/timm/mobilenetv5_300m.gemma3n) (used in Gemma-3n) which enables better on-device hardware usage compared to SigLIP. MobileNetV5 can be run entirely on the neural engine (where as SigLIP uses much of the GPU via MLX). Future works would involve potentially replacing the [MedSigLIP](https://developers.google.com/health-ai-developer-foundations/medsiglip) vision encoder with MobileNetV5, however, this would likely require a significant retraining on medical-related data.
* **Increase data for fine-tuning.** Our fine-tuning dataset only spans ~1.1k samples with a Gemini 3 Flash teacher. Future works would largely increase this dataset size as well as get official inputs from professional dermatologists on actual smartphone-taken images (current skin images are from the ISIC-2024 dataset which are crops from full body scans) to guide the model. 
* **Hard negative training.** Right now our model will generate a response no matter what image is uploaded on device. To prevent unwanted generations, future fine-tuning datasets would likely include a significant number of images of what to reject. For example, if someone uploads a photo of their dog accidentally, we’d prefer the model not to start extracting skin-related details.

## References

[^1]: Dorothea Mackellar. "My Country" (1908). — "I love a sunburnt country, a land of sweeping plains." [Link](https://www.dorotheamackellar.com.au/my-country)

[^2]: Cancer Council Australia. Skin Cancer Incidence and Mortality. — "Australia and New Zealand have the highest melanoma incidence rates in the world, 2–3× higher than the US and UK." [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/skin-cancer-incidence-and-mortality)

[^3]: Australian Skin Cancer Foundation (2024). Skin Cancer Australia Statistics. — Combined melanoma and keratinocyte cancer deaths estimated ~2,105 in 2023 (source: ACD). [Link](https://www.australianskincancerfoundation.org/skin-cancer-australia-statistics)

[^4]: SunSmart / Cancer Council Victoria. Skin cancer facts & stats. — "About 2,000 Australians die from skin cancer each year." [Link](https://www.sunsmart.com.au/skin-cancer/skin-cancer-facts-stats)

[^5]: Cancer Council Australia. — "Skin cancer causes more deaths than transport accidents every year in Australia." [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/skin-cancer-incidence-and-mortality)

[^6]: Australasian College of Dermatologists (ACD) / MSCAN. Australia’s National Skin Cancer Scorecard Report 2025 – Full Report. — Notes 2023/24 melanoma cost $596 million (and total skin cancer cost $2.47 billion). [Link](https://www.dermcoll.edu.au/wp-content/uploads/2025/11/2025-REPORT_SKIN-CANCER-SCORECARD.pdf)

[^7]: Australasian College of Dermatologists (ACD) / MSCAN. Australia’s National Skin Cancer Scorecard Report 2025 – Full Report. — Notes keratinocyte cancers cost $1.87 billion in 2023/24 and skin cancer is the most costly cancer to treat in Australia. [Link](https://www.dermcoll.edu.au/wp-content/uploads/2025/11/2025-REPORT_SKIN-CANCER-SCORECARD.pdf)

[^8]: Gordon LG, et al. / QIMR Berghofer Medical Research Institute. "Estimated Healthcare Costs of Melanoma and Keratinocyte Skin Cancers in Australia and Aotearoa New Zealand in 2021." *International Journal of Environmental Research and Public Health*. 2022. — Mean first-year cost: AU$644 (in situ), AU$1,681 (Stage I/II), AU$37,729 (Stage III resectable), AU$100,725 (Stage III/IV unresectable), AU$187,720 (3-year Stage III/IV). [Link](https://pubmed.ncbi.nlm.nih.gov/35328865/)

[^9]: AIHW / NCCI (2018). Relative survival by stage at diagnosis (melanoma) — based on 2011 Australian Cancer Database cohort. Stage I ~99–100% 5-year survival; Stage III ~61–72% (3-year, varies by age); Stage IV ~26%. [Link](https://ncci.canceraustralia.gov.au/outcomes/relative-survival-rate/relative-survival-stage-diagnosis-melanoma)

[^10]: SunSmart / Cancer Council Victoria. — SunSmart program has been running since 1988; generates $2.30 net saving for every $1 spent. [Link](https://en.wikipedia.org/wiki/SunSmart)

[^11]: Elliott TM, Whiteman DC, Olsen CM, Gordon LG. "Estimated Healthcare Costs of Melanoma in Australia Over 3 Years Post-Diagnosis." Applied Health Economics and Health Policy. 2017;15:805–816. (Reports mean annual costs including AU$1,681 for Stage 0/I/II and AU$37,729 for Stage III resectable, plus 3-year cost AU$187,720 for Stage III unresectable/IV.) [Link](https://pmc.ncbi.nlm.nih.gov/articles/PMC8948716/)

[^12]: Australian Government Department of Health and Aged Care / Standing Committee on Screening. "Skin cancer screening – position statement." 2017. (Explains why Australia does not have a national skin cancer screening program and endorses Cancer Council Australia advice; does not recommend mass/population-based screening for melanoma due to insufficient evidence of reduced morbidity/mortality.) [Link](https://www.health.gov.au/resources/publications/skin-cancer-screening-position-statement?language=en) Also see: RACGP. "Skin cancer" in *Guidelines for preventive activities in general practice* (recommendation table; average/below-average risk: regular skin checks not recommended). 28 June 2024. [Link](https://www.racgp.org.au/clinical-resources/clinical-guidelines/key-racgp-guidelines/view-all-racgp-guidelines/preventive-activities-in-general-practice/cancer/skin-cancer)

[^13]: Cancer Council Australia. "Early Detection of Skin Cancer – Position Statement." 2019. (States population screening programs are not recommended; supports opportunistic screening by general practitioners for people at high risk, and recommends individuals consult a doctor for new/changing lesions. Notes high-risk individuals should have clinical skin examinations every 6–12 months, and those at very high risk may be advised to have 6-monthly full skin examinations supported by photography/dermoscopy, alongside regular self-examination.) [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/early-detection) Also see: Supporting RACGP guidance on high-risk self-check frequency (often cited in Australian primary care resources): The Royal Australian College of General Practitioners. "Skin checks." *Australian Family Physician*. 2012. (Risk table includes: high risk = 3-monthly self-examination and 12-monthly skin check with a doctor.) [Link](https://www.racgp.org.au/afp/2012/july/skin-checks)

[^14]: Cancer Council Australia. Position Statement: Screening and early detection of skin cancer. — "The majority of melanomas are detected by patients themselves or their partners." [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/early-detection)

[^15]: Cancer Council Australia. Detection and screening (UV Radiation: Related resources), section "Skin self-examination". Notes that "A Queensland study found nearly half (44%) of those with histologically confirmed melanoma detected the melanoma themselves." [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/detection-and-screening)

[^16]: Australian Bureau of Statistics. National Health Survey 2013–14 (n=19,000+). As cited in Cancer Council Australia, Detection and Screening. — "Two-thirds (66%) of Australians regularly check their skin for changes in freckles and moles." [Link](https://www.cancer.org.au/about-us/policy-and-advocacy/prevention/uv-radiation/related-resources/detection-and-screening)

[^17]: Cust AE, et al. "Prevalence of skin examination behaviours among Australians over time." *Preventive Medicine Reports*. 2021;21:101316. — National Sun Protection Survey (2016–17, n=23,374): only 22% reported whole-body skin checks in the past 12 months; 64% reported no skin checks at all. [Link](https://pubmed.ncbi.nlm.nih.gov/33341599/)

[^18]: Berwick M, Begg CB, Fine JA, Roush GC, Barnhill RL. "Screening for cutaneous melanoma by skin self-examination." *Journal of the National Cancer Institute*. 1996;88(1):17–23. — SSE may reduce melanoma mortality by 63%. [Link](https://pubmed.ncbi.nlm.nih.gov/8847720/)

[^19]: Aitken JF, Janda M, Youl PH, Lowe JB, Ring IT, Elwood M. 'Clinical outcomes from skin screening clinics within a community-based melanoma screening program.' Journal of the American Academy of Dermatology. 2004;50(1):105–114. — Reports 25.9% performed whole-body skin self-examination in the past 12 months (Queensland, Australia). [Link](https://pubmed.ncbi.nlm.nih.gov/15286465/)