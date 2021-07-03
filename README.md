# DzAPI_Convert

## Description
The main script `convert_dz_api.R` functions to convert all Dz API natives in war3map.j to regular functions

## Installation via Conda
```
# Clone the repo
git clone https://github.com/jimmyliu1326/DzAPI_Convert.git

# Change working directory
cd DzAPI_Convert

# Install conda environment called dzapi_convert
conda env create -f conda_env.yaml

# Activate conda environment
conda activate dzapi_convert
```

## Usage
* Run the command line below to convert
* Make sure the `convert_dz_api.R` is in current working directory or has been added to $PATH
```
Rscript convert_dz_api.R path/to/war3map.j path/to/output_file
```
