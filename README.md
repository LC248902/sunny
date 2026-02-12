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
* ✅ Read Australia's national skin cancer report card - https://www.dermcoll.edu.au/wp-content/uploads/2025/11/2025-REPORT_SKIN-CANCER-SCORECARD.pdf 
    * Done - many relavant points to our cause, especially costs, pros of early detection and a future avenue for ongoing support for patients who have been diagnosed with skin cancer but aren't sure what to do next, this seemed to be one of the biggest gaps in the report (ongoing support for life after diagnosis is minimal)
* ✅ Investigate the SLICE-3D dataset and see if this can be integrated into what we're making - https://challenge2024.isic-archive.com/
    * Done - using 1000 of these (they are quite low quality) for fine-tuning MedGemma 
* ✅ Contact another expert to get their advice on skin cancer + prevention + new technologies entering the field and how they're shaping dermatology.
    * Done - reached out to 3x experts/doctors so far but have yet to hear back, if this doesn't happen we may benchmark it and try another route 

## Log

* **12 Feb 2026** - Going to fine-tune MedGemma-1.5 to be able to extract details from sunscreen packaging as well as extract details from dermatology photos. This will better align the model with our app's use cases.
    * Dataset to create: ~100 sunscreen photos with front and back extractions + ~1000 skin images with descriptions - these will be labelled with `gemini-3-flash-preview` and then distilled into MedGemma (hopefully this works)
        * Skin images come from [ISIC-2024 permissive license images](https://challenge2024.isic-archive.com/) and are a combined sample of: all malignant samples (294), all ideterminate samples (100), random benign samples to make it up to 1000 (606)
        * **Note:** Many of the images are quite low resolution... so might be hard to get a decent extraction from them. This may not translate well to on-device photos. Regardless, we will try to fine-tune and deploy a model! [Genchi genbutsu](https://en.wikipedia.org/wiki/Genchi_Genbutsu): Always test in the actual use case!
    * Going to save the dataset to Hugging Face with a simple format of "skin extract" + image -> skin output or "sunscreen extract" + image -> sunscreen output
        * I'll then fine-tune MedGemma-1.5 to reproduce these outputs and we'll put them in the app 
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