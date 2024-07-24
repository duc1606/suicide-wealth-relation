import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the Human Development Index data
df = pd.read_csv("csv_files/Human_Development_Index.csv")

# List of selected countries in the specified order
combined_countries_ordered = [
    "Slovenia", "Bulgaria", "Austria", "Lithuania", "Switzerland", "Hungary",
    "France", "Estonia", "Latvia", "Croatia", "Finland", "Russian Federation",
    "Sri Lanka", "Nicaragua", "Canada", "Italy", "Turkmenistan", "Denmark",
    "Luxembourg", "United Kingdom", "Czechia", "Germany", "Belgium", "Ukraine",
    "Serbia", "Norway", "Sweden", "Israel", "Belarus", "Singapore", "El Salvador",
    "Kyrgyzstan", "Kazakhstan", "Kiribati", "Australia", "Mauritius", "Slovakia",
    "New Zealand", "Panama", "Netherlands", "Argentina", "Saint Lucia", "Thailand",
    "Maldives", "Romania", "Iceland", "Azerbaijan", "Greece", "Spain", "Albania",
    "Armenia", "Seychelles", "Mongolia", "United States", "Georgia", "Japan",
    "Colombia", "Portugal", "Jamaica", "Costa Rica", "Ireland", "Ecuador", "Poland",
    "Belize", "Uruguay", "South Africa", "Malta", "Guyana", "Guatemala", "Cyprus",
    "Turkey", "Chile", "Paraguay", "Montenegro", "Philippines", "Suriname", "Brazil",
    "South Korea", "Mexico", "Bosnia and Herzegovina"
]

# Filter the DataFrame for the selected countries
filtered_df = df[df['Country'].isin(combined_countries_ordered)].copy()

# List of HDI columns for the years 1990-2021
hdi_columns = [
    'Human Development Index (1990)', 'Human Development Index (1991)', 'Human Development Index (1992)',
    'Human Development Index (1993)', 'Human Development Index (1994)', 'Human Development Index (1995)',
    'Human Development Index (1996)', 'Human Development Index (1997)', 'Human Development Index (1998)',
    'Human Development Index (1999)', 'Human Development Index (2000)', 'Human Development Index (2001)',
    'Human Development Index (2002)', 'Human Development Index (2003)', 'Human Development Index (2004)',
    'Human Development Index (2005)', 'Human Development Index (2006)', 'Human Development Index (2007)',
    'Human Development Index (2008)', 'Human Development Index (2009)', 'Human Development Index (2010)',
    'Human Development Index (2011)', 'Human Development Index (2012)', 'Human Development Index (2013)',
    'Human Development Index (2014)', 'Human Development Index (2015)', 'Human Development Index (2016)',
    'Human Development Index (2017)', 'Human Development Index (2018)', 'Human Development Index (2019)',
    'Human Development Index (2020)', 'Human Development Index (2021)'
]

# Calculate the average HDI over all years
filtered_df['Average HDI'] = filtered_df[hdi_columns].mean(axis=1)

# Ensure the countries are ordered as per the combined list
filtered_df['Country'] = pd.Categorical(filtered_df['Country'], categories=combined_countries_ordered, ordered=True)
filtered_df = filtered_df.sort_values('Country')

# Create a numerical index for the countries
filtered_df['index'] = range(len(filtered_df))

# Create the bar plot
plt.figure(figsize=(18, 12))
sns.barplot(x='Country', y='Average HDI', data=filtered_df, hue='Country', palette='YlOrRd', dodge=False)
plt.xticks(rotation=90)
plt.xlabel('Country')
plt.ylabel('Average Human Development Index (1990-2021)')
plt.title('Average Human Development Index (1990-2021) of Selected Countries')

# Add a trend line using the numerical index
sns.regplot(x='index', y='Average HDI', data=filtered_df, scatter=False, color='blue')

plt.tight_layout()
plt.show()

# Columns with the expected years of schooling for the years 1990-2021
schooling_columns = [
    'Expected Years of Schooling (1990)', 'Expected Years of Schooling (1991)', 'Expected Years of Schooling (1992)',
    'Expected Years of Schooling (1993)', 'Expected Years of Schooling (1994)', 'Expected Years of Schooling (1995)',
    'Expected Years of Schooling (1996)', 'Expected Years of Schooling (1997)', 'Expected Years of Schooling (1998)',
    'Expected Years of Schooling (1999)', 'Expected Years of Schooling (2000)', 'Expected Years of Schooling (2001)',
    'Expected Years of Schooling (2002)', 'Expected Years of Schooling (2003)', 'Expected Years of Schooling (2004)',
    'Expected Years of Schooling (2005)', 'Expected Years of Schooling (2006)', 'Expected Years of Schooling (2007)',
    'Expected Years of Schooling (2008)', 'Expected Years of Schooling (2009)', 'Expected Years of Schooling (2010)',
    'Expected Years of Schooling (2011)', 'Expected Years of Schooling (2012)', 'Expected Years of Schooling (2013)',
    'Expected Years of Schooling (2014)', 'Expected Years of Schooling (2015)', 'Expected Years of Schooling (2016)',
    'Expected Years of Schooling (2017)', 'Expected Years of Schooling (2018)', 'Expected Years of Schooling (2019)',
    'Expected Years of Schooling (2020)', 'Expected Years of Schooling (2021)'
]

# Calculate the average expected years of schooling over all years
filtered_df['Average Expected Years of Schooling'] = filtered_df[schooling_columns].mean(axis=1)

# Ensure the countries are ordered as per the combined list
filtered_df['Country'] = pd.Categorical(filtered_df['Country'], categories=combined_countries_ordered, ordered=True)
filtered_df = filtered_df.sort_values('Country')

# Create a numerical index for the countries
filtered_df['index'] = range(len(filtered_df))

# Create the bar plot
plt.figure(figsize=(18, 12))
sns.barplot(x='Country', y='Average Expected Years of Schooling', data=filtered_df, hue='Country', palette='YlOrRd', dodge=False, legend=False)
plt.xticks(rotation=90)
plt.xlabel('Country')
plt.ylabel('Average Expected Years of Schooling (1990-2021)')
plt.title('Average Expected Years of Schooling (1990-2021) of Selected Countries')

plt.tight_layout()
plt.show()