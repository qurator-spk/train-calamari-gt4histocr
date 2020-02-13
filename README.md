Train a GT4HistOCR Calamari model
=================================

`train.sh` trains a Calamari model based on GT4HistOCR. Or rather 5 using
cross-validation to use for confidence voting. This repository mainly 
serves as documentation of the provenance of the model published at 
https://qurator-data.de/calamari-models/, not as the definitive guide to
training such a model.

Trained models
--------------
For a finished model have a look here:
https://qurator-data.de/calamari-models/

Training your own model
-----------------------
If you really want to, you can use this script to train your own. It takes
about 1 week on a Nvidia RTX 2080 GPU. Please use [requirements.txt](requirements.txt)
in that case to setup a virtualenv.

`train.sh` is able to download GT4HistOCR from the web if the `data` submodule
is not available, that is if you're not a member of the Qurator team at SBB.
