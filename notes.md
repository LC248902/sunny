# Misc Notes Related to the Project

## Paper Reading: The SLICE-3D dataset: 400,000 skin lesion image crops extracted from 3D TBP for skin cancer detection

Link: https://www.nature.com/articles/s41597-024-03743-w 

* Melanoma (MM), Basal Cell Carcinoma (BCC), Squamous Cell Carcinoma (SCC) 
* SLICE-3D (Skin Lesion Image Crops Extracted from 3D TBP) 
    * Dataset: 400,000+ standardized, de-identified and diagnostically labelled skin images relevant to use-cases outside of specialized clinics.
    * 💡 Image quality resembles cropped smartphone photos, which are regularly submitted by patients to their clinicans for telehealth purposes.
* Images sourced and extracted from 3D total body photographs (3D TBP) - this is a series of DSLR cameras (92 cameras total, 46 pairs) fixed in an apparatus to capture the complete visible cutaneous surface area.
* Samples from 1000+ patients between 2015 and 2024 across three continents.
* Benign moles on an individual tend to resemble each other in terms of color, shape, size and pattern while outlier lesions exhibit more of an "ugly duckling sign". 
* Image exports: 15mm-by-15mm field of view cropped images centered on each lesion are exported for automatically detected lesions larger than 2.5mm and for all manually tagged lesions regardless of size. 
* "Strong-labels" = sample images which have a pathology report for a primary biopsy performed within 3 months of the 3D TBP capture.
* "Weak-labels" = sample images which are assumed benign based on clinical evaluation, which were not assosciated with a reported biopsy.
* All image embeddings were extracted using the MONET model published by Kim et al - https://www.nature.com/articles/s41591-024-02887-x 
    * See model on Hugging Face here: https://huggingface.co/suinleelab/monet 
    * See GitHub example of labelling concepts: https://github.com/suinleelab/MONET/blob/main/tutorial/automatic_concept_annotation.ipynb 
* Images under 3 Creative Commons Licenses - CC-0, CC-BY, CC-BY NC.
    * From Gemini:
        * CC0 (Creative Commons Zero): This is a "no rights reserved" public domain dedication that allows creators to waive all copyright interests, letting others use the work for any purpose without restriction or attribution.
        * CC BY (Attribution): This license allows others to distribute, remix, adapt, and build upon a work—even commercially—as long as they provide proper credit to the original creator.
        * CC BY-NC (Attribution-NonCommercial): This license permits others to remix, adapt, and build upon a work as long as they credit the creator, provided the use is not for commercial purposes.
* Paper - "A multimodal vision foundation model for clinical dermatology" - https://www.nature.com/articles/s41591-025-03747-y 
