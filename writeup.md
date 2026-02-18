# Sunny - Kaggle Competition Writeup Template

See link to writeup critera: https://www.kaggle.com/competitions/med-gemma-impact-challenge/overview 

## Quick Links

* TK - Our dataset - 
* TK - Our fine-tuned MedGemma-1.5 model - 
* TK - The code to our app Sunny - 
* TK - Writeup link (you're currently reading this) - 
* TK - Video link - 

## Project Name

Sunny - an app to help people track their skin health over time.

## Your Team

* Daniel Bourke (@mrdbourke) — Machine Learning Engineer, handled fine-tuning of MedGemma, dataset creation and conversion steps to enable the model to run on-device.
* Joshua Bourke — iOS Engineer, handled app creation and model integration to run on-device.

## Problem Statement (30% total)

> Your answer to “Problem domain” & “Impact potential” criteria.

### Problem Domain (15%)

> Criteria: How important is this problem to solve and how plausible is it that AI is right solution?
> Assessment: You will be assessed on: storytelling, clarity of problem definition, clarity on whether there is an unmet need, the magnitude of the problem, who the user is and their improved journey given your solution.

Australia is known for its beaches and vast plains.

Some poets even refer to it as the sunburnt country.

However, this sunburn comes at a cost.

Australia has the highest ratio of skin cancer in the world. 

This year, it’s estimated 2000 Australians will die of skin cancer (TK - back this up). 

A tragic outcome of the sun we love so much.

Cost wise, in 2023/2024 skin cancer cost the Australian health care system $2.4B (TK - resource).

TK image - graph showing the costs and sources 

When it comes to treatments, the numbers are clear.

If discovered early, a skin cancer (TK - names of them) can often be treated at a general practitioner or GP for a cost of $500-$1000.

However, if treatment has to move to a hospital because of the skin cancer being at a later stage, treatment costs quickly ramp to $10,000 for Stage III (TK - clarify) or upwards of $100,000 for later stages requiring more advanced treatments (TK - clarify).

In terms of mortality, a skin cancer discovered and treated early has a 99-100% chance survival rate over five years.

Whereas survival rate drops to 25-32% (TK - clarify) if a skin cancer reaches Stage III or IV.

Researchers and health professionals agree, prevention is the best cure.

And Australia invests millions of (TK - figure) dollars in marketing campaigns discussing sun safety techniques with an estimated cost of $3.20 saved per $1 invested (TK - source). 

But even with all of this, there is currently no national screening program.

The current recommended approach is to “perform self-skin examinations” and “visit a skin doctor once per year or when you notice a change”.

So far this approach has performed well with ~44% of melanomas (TK - source) discovered by patients themselves or with a partner. 

But we think this could be better.

That’s where Sunny comes in.

Sunny fills the gap of the lack of national screening program at a minimal cost.

Our primary user is an Australian adult aged 30–70 who is aware of skin cancer risk and believes they monitor their skin, but does not perform a structured whole-body examination, the gap between the 66% who say they check and the 26% who actually do (TK - resources). 

Sunny transforms a vague “perform self-skin examinations” recommendation into a structured and repeatable full body self-skin examination habit with trackable progress.

TK - Sunny workflow example here: what does Sunny actually do?

* Storytelling: Australia is known for its beaches... is referred to as the sunburnt country... however, this sunburn often comes at a cost 
* Unmet need: No nation-wide screening, no matter, Sunny puts the power into the hands of the user, running on the tailwinds of 44% of all melanomas being discovered by patients themselves or partners 
* Magnitude of the problem: $2.5B on skin cancer, early treatment costs are far smaller than later treatment costs, not to mention far more effective 
* Who is our user? What is their improved journey?

TK -- Sunny’s ideal user: Our primary user is an Australian adult aged 30–69 who is aware of skin cancer risk and believes they monitor their skin, but does not perform a structured whole-body examination — the gap between the 66% who say they check and the 26% who actually do. Sunny converts their good intention into a guided, repeatable habit with trackable progress, replacing vague self-reassurance with confident, thorough self-examination.

### Impact Potential (15%)

> Criteria: If the solution works, what impact would it have?
> Assessment: You will be assessed on: clear articulation of real of anticipated impact of your application within the given problem domain and description of how you calculated your estimates. 

* Our anticipated impact: We’d like Sunny to become the national standard for self-skin-examination, a central place where people can keep track of their skin and potential changes over time. We’d like the numbers of people who report self-examination to increase from XX to YY.
	* TK - What will this impact do? Let’s get some numbers behind it.

Our vision is for Sunny to become the national standard for self-skin-examination.

A central place where people can keep track of their skin and potential changes overtime.

No more vague memories of what a skin spot used to look like, Sunny provides a structured way for thorough self-skin-examination and tracking over time.

Our goal with Sunny is to increase the percentage of people who perform regular self-skin-examinations from XX to YY.

TK - If successful, TK - fill in the numbers here... 

## Overall Solution (20%)

> Your answer to “Effective use of HAI-DEF models” criterion.
> Criteria: 
> Whether the submission proposes an application that uses HAI-DEF models to their fullest potential, where other solutions would likely be less effective. 

Sunny is an iOS application which runs a fine-tuned version of MedGemma-1.5-4B called Sunny-MedGemma on device via Apple’s MLX framework.

Due to the sensitive nature of skin photographs, using an API-based model solution was out of the question.

All data within the Sunny App is passcode protected and never leaves the user’s device. 

When a user takes a photo of their skin, Sunny-MedGemma generates a structured description in a similar format to what a dermatologist would report on.

This inference happens completely on-device.

MedGemma-1.5-4B fits as the perfect base model for this workflow  for a number of reasons:

* **Small enough to run on-device:** MedGemma-1.5-4B brings AI to where people are, their own devices. Users of Sunny can be confident no data will ever leave their device for inference. Because Sunny-MedGemma runs on device, this also means inference cost is next to zero, meaning Sunny could be deployed to millions of people without significantly increasing costs.
* **Trained a vast number of medical images:** The data card for MedGemma-1.5-4B lists a large amount of dermatology-related datasets used in training. This means the model already has a good representation of the type of skin images seen in the Sunny workflow. Other models have good broad vision and language capabilities and could potentially be fine-tuned for our workflow, however, this would likely take far more effort. Hence, MedGemma’s medical focus wins out over these.
* **Better structured data generation:** Much better at structured data outputs than the previous generation (this is important for crafting reliable and readable reports).

* MedGemma already trained on much of ISIC data so it’s in the latent space
* Much better at structured data JSON generation
* Many different dermatology datasets already in the training data (Dermatology dataset 1->6) 
* Other models have a broad capability but don’t have this kind of data in the pre-training data so would likely require more effort to tailor towards the medical space 
* Crucially: MedGemma-4B is small enough to run on a phone device, the AI meets people where they are 

## Technical Details (20%)

> Your answer to “Product feasibility” criterion.
> **Criteria:** Is the technical solution clearly feasible?
> **Assessment:** You will be assessed on: technical documentation detailing model fine-tuning, model’s performance analysis, your user-facing application stack, deployment challenges and how you plan on overcoming them. Consideration of how a product might be used in practice, rather than only for benchmarking.

UPTOHERE:
- technical details, make performance analysis with structured/unstructured data 
- go back through report and add details
- update the impact statement

* Technical documentation

-> Sunny workflow walkthrough - how does Sunny work?
-> GitHub repo + links

* Model’s performance analysis

-> Compare fine-tuned model to original model
-> “We fine-tune to enable smaller prompt inputs to save on memory. When you’re executing models on-device, every token counts.” 

* User-facing application stack
* Deployment challenges + how you plan on overcoming them

-> Discuss the lowering of precision and how this impacts performance 

* How a product might be used in practice, rather than only for benchmarking

### Limitations and future work

* Improve model performance at lower quantization levels
* Increase data for fine-tuning
* False positive rejection - what if someone uploads an image of “not skin”?

## Sources

* Australian Institute of Health and Welfare: Health system spending on disease and injury in Australia 2023–24 - https://www.aihw.gov.au/reports/health-welfare-expenditure/health-system-spending-disease-injury-aus-2023-24/contents/spending-on-disease-by-abod-conditions 
* Estimated Healthcare Costs of Melanoma and Keratinocyte Skin Cancers in Australia and Aotearoa New Zealand in 2021 - https://pmc.ncbi.nlm.nih.gov/articles/PMC8948716/ 
    * Cite: Gordon et al. 2022, Int J Environ Res Public Health (stage-by-stage melanoma costs, KC mean cost): PMC8948716 
* Non-melanoma skin cancer: general practice consultations, hospitalisation and mortality - https://www.aihw.gov.au/reports/cancer/non-melanoma-skin-cancer/summary 