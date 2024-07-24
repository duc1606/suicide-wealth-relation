import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Read the Gini Coefficient data
df = pd.read_csv("csv_files/Gini_Coefficient.csv")

# Combined list of selected countries in the specified order
combined_countries_ordered = [
    "Slovenia", "Bulgaria", "Austria", "Lithuania", "Switzerland", "Hungary",
    "France", "Estonia", "Latvia", "Croatia", "Finland", "Russia",
    "Sri Lanka", "Nicaragua", "Canada", "Italy", "Turkmenistan", "Denmark",
    "Luxembourg", "United Kingdom", "Czech Republic", "Germany", "Belgium", "Ukraine",
    "Serbia", "Norway", "Sweden", "Israel", "Belarus", "Singapore", "El Salvador",
    "Kyrgyzstan", "Kazakhstan", "Kiribati", "Australia", "Mauritius", "Slovakia",
    "New Zealand", "Panama", "Netherlands", "Argentina", "Saint Lucia", "Thailand",
    "Maldives", "Fiji", "Romania", "Uzbekistan", "Trinidad and Tobago", "Iceland",
    "Azerbaijan", "Greece", "Spain", "Albania", "Armenia", "Seychelles", "Mongolia",
    "United States", "Qatar", "United Arab Emirates", "Georgia",
    "Japan", "Colombia", "Portugal", "Jamaica", "Costa Rica", "Ireland", "Ecuador",
    "Poland", "Belize", "Uruguay", "South Africa", "Malta", "Guyana", "Guatemala",
    "Cyprus", "Turkey", "Chile", "Paraguay", "Montenegro", "Philippines", "Suriname",
    "Brazil","South Korea", "Mexico", "Bosnia and Herzegovina"
]

# Filter the DataFrame for the combined list of countries
filtered_df = df[df['country'].isin(combined_countries_ordered)].copy()

# Add specified Gini coefficient values
additional_gini_values = {
    "Singapore": 45.9,
    "Slovakia": 24.1,
    "New Zealand": 33.9,
    "Qatar": 41.1
}

for country, gini_value in additional_gini_values.items():
    filtered_df.loc[filtered_df['country'] == country, 'giniWB'] = gini_value

# Ensure the countries are ordered as per the combined list
filtered_df['country'] = pd.Categorical(filtered_df['country'], categories=combined_countries_ordered, ordered=True)
filtered_df = filtered_df.sort_values('country')

# Create a numerical index for the countries
filtered_df['index'] = range(len(filtered_df))

# Create the bar plot
plt.figure(figsize=(18, 12))
sns.barplot(x='country', y='giniWB', data=filtered_df, palette='YlOrRd', hue='country', dodge=False, legend=False)
plt.xticks(rotation=90)
plt.xlabel('Country')
plt.ylabel('Gini Coefficient')
plt.title('Gini Coefficients of Selected Countries')

# Add a trend line using the numerical index
sns.regplot(x='index', y='giniWB', data=filtered_df, scatter=False, color='blue')

plt.tight_layout()
plt.show()
