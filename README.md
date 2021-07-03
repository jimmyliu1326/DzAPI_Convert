# DzAPI_Convert

## Installation
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
* Run the below command line to convert Dz API natives to functions
* Make sure the `convert_dz_api.R` is in current working directory or have been added to $PATH
```
Rscript convert_dz_api.R path/to/war3map.j path/to/output_file
```
