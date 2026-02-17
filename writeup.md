# Sunny - Kaggle Competition Writeup Template

See link to writeup critera: https://www.kaggle.com/competitions/med-gemma-impact-challenge/overview 

## Quick Links

* TK - Our dataset - 
* TK - Our fine-tuned MedGemma-1.5 model - 
* TK - The code to our app Sunny - 
* TK - Writeup link (you're currently reading this) - 
* TK - Video link - 

## Project Name

Sunny - an app to help people track their skin over time.

## Your Team

* Daniel Bourke (@mrdbourke) — Machine Learning Engineer, handled fine-tuning of MedGemma, dataset creation and conversion steps to enable the model to run on-device.
* Joshua Bourke — iOS Engineer, handled app creation and model integration to run on-device.

## Problem Statement (30% total)

> Your answer to “Problem domain” & “Impact potential” criteria.

### Problem Domain (15%)

> Criteria: How important is this problem to solve and how plausible is it that AI is right solution?
> Assessment: You will be assessed on: storytelling, clarity of problem definition, clarity on whether there is an unmet need, the magnitude of the problem, who the user is and their improved journey given your solution.

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

## Overall Solution (20%)

> Your answer to “Effective use of HAI-DEF models” criterion.
> Criteria: 
> Whether the submission proposes an application that uses HAI-DEF models to their fullest potential, where other solutions would likely be less effective. 

* MedGemma already trained on much of ISIC data so it’s in the latent space
* Much better at structured data JSON generation
* Many different dermatology datasets already in the training data (Dermatology dataset 1->6) 
* Other models have a broad capability but don’t have this kind of data in the pre-training data so would likely require more effort to tailor towards the medical space 
* Crucially: MedGemma-4B is small enough to run on a phone device, the AI meets people where they are 

## Technical Details (20%)

> Your answer to “Product feasibility” criterion.
> **Criteria:** Is the technical solution clearly feasible?
> **Assessment:** You will be assessed on: technical documentation detailing model fine-tuning, model’s performance analysis, your user-facing application stack, deployment challenges and how you plan on overcoming them. Consideration of how a product might be used in practice, rather than only for benchmarking.

* Technical documentation
* Model’s performance analysis
* User-facing application stack
* Deployment challenges + how you plan on overcoming them
* How a product might be used in practice, rather than only for benchmarking

## Sources

* Australian Institute of Health and Welfare: Health system spending on disease and injury in Australia 2023–24 - https://www.aihw.gov.au/reports/health-welfare-expenditure/health-system-spending-disease-injury-aus-2023-24/contents/spending-on-disease-by-abod-conditions 
* Estimated Healthcare Costs of Melanoma and Keratinocyte Skin Cancers in Australia and Aotearoa New Zealand in 2021 - https://pmc.ncbi.nlm.nih.gov/articles/PMC8948716/ 
    * Cite: Gordon et al. 2022, Int J Environ Res Public Health (stage-by-stage melanoma costs, KC mean cost): PMC8948716 
* Non-melanoma skin cancer: general practice consultations, hospitalisation and mortality - https://www.aihw.gov.au/reports/cancer/non-melanoma-skin-cancer/summary 