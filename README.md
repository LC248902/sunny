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

### TK - Problem

### TK - Science

### TK - Gap

### TK - Solution

## Next

* Read Australia's national skin cancer report card - https://www.dermcoll.edu.au/wp-content/uploads/2025/11/2025-REPORT_SKIN-CANCER-SCORECARD.pdf 
* Investigate the SLICE-3D dataset and see if this can be integrated into what we're making - https://challenge2024.isic-archive.com/
* Upgrade the workflow of MedGemma running on iOS, can the app design be cleaner? 
* Contact another expert to get their advice on skin cancer + prevention + new technologies entering the field and how they're shaping dermatology.

## Log

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