# README

## Project: Suicide-Wealth Relation Analysis

This repository contains the code and data for analyzing the relationship between suicide rates and various economic and social indicators. The aim of this project is to investigate if there is a correlation between these factors and the suicide rates in different countries.

## Table of Contents

- [Introduction](#introduction)
- [Data](#data)
- [Installation](#installation)
- [Usage](#usage)
- [Files Description](#files-description)
- [Results](#results)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Introduction

Understanding the factors that influence suicide rates is crucial for public health policies and interventions. This project explores the potential relationships between a country's economic and social indicators and its suicide rates. By analyzing global data, we hope to uncover patterns and correlations that could inform future research and policy-making.

## Data

The datasets used in this project are sourced from various reputable sources including:

- World Health Organization (WHO) for suicide rates
- World Bank for economic indicators
- Additional datasets for social indicators

The data includes information on suicide rates per 100,000 people and various indicators such as GDP per capita, Gini coefficient, health expenses, Human Development Index (HDI), and sunshine duration.

### Data Sources

- [Human Development Index Dataset](https://www.kaggle.com/datasets/iamsouravbanerjee/human-development-index-dataset)
- [Gini Coefficient of Countries](https://www.kaggle.com/datasets/therockk/gini-coefficient-of-countries)
- [Suicide Rates Overview 1985 to 2016](https://www.kaggle.com/datasets/russellyates88/suicide-rates-overview-1985-to-2016)

## Installation

### Python

To run the Python analyses, you'll need to have Python installed along with several libraries. You can install the required libraries using pip:

```bash
pip install -r requirements.txt
```

The main libraries used in this project are:

- pandas
- matplotlib
- seaborn

### R

For the R analyses, you need to install the required packages. You can install them by running the following commands in your R console:

```R
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyr")
```

## Usage

To perform the analysis, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/duc1606/suicide-wealth-relation.git
    cd suicide-wealth-relation
    ```

2. Ensure you have the required libraries installed (see [Installation](#installation)).

3. Run the analysis scripts as needed. For example, to run the Python script for analyzing the Gini coefficient:
    ```bash
    python gini_coefficient_analysis.py
    ```

    Or to run the R script for analyzing GDP and suicide rates:
    ```R
    Rscript gdp_suicide_rate_analysis.R
    ```

## Files Description

### Python Scripts

- **gini_coefficient_analysis.py**: Displays the Gini coefficient for each country sorted by the correlation coefficient with suicide rates.
- **human_development_index_analysis.py**: Displays the Human Development Index (HDI) for each country sorted by the correlation coefficient with suicide rates.

### R Scripts

- **correlation_and_trends_analysis.R**: General analysis of correlation and trends between various indicators and suicide rates.
- **gdp_suicide_rate_analysis.R**: Analyzes the relationship between GDP per capita and suicide rates.
- **health_expenses_analysis.R**: Displays the health expenses for each country sorted by the correlation coefficient with suicide rates.
- **sunshine_analysis.R**: Displays the sunshine duration for each country sorted by the correlation coefficient with suicide rates.

## Results

The results of the analyses are saved in the `suicide-wealth-pp.pdf` directory. This includes:

- Summary statistics
- Correlation matrices
- Visualizations (e.g., scatter plots, bar charts)
- Model performance metrics

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please:

1. Fork the repository
2. Create a new branch (`git checkout -b feature-xyz`)
3. Make your changes
4. Submit a pull request

Please ensure your code follows the project's coding standards and includes appropriate tests.
