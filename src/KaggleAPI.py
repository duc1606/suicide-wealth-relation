import pandas as pd
import os
import opendatasets as od
import requests
import csv
import seaborn as sns
import matplotlib.pyplot as plt

# i created a new API token for kaggle
# this step creates a .json file containing only the following line:
#{"username":"cerenkulekci","key":"a0ec96c859204d99cf38eadf80b8961f"}

#  the Kaggle data set URL
dataset = 'https://www.kaggle.com/datasets/russellyates88/suicide-rates-overview-1985-to-2016/data'
# using opendatasets to download the data sets
od.download(dataset)
#this creates
data_dir = './csv_files'
# i used the os library to list the files inside dir
# this step required my username and key as input i already did it and thats how i downloaded the csv
# named 'master.csv' into this project
class_name=type(os.listdir(data_dir)).__name__
print(class_name) #list
#this returns the files inside the dir as a list

#i got the length of this list
#it is 1 because we only have 1 csv file
print(len(os.listdir(data_dir))) #1
#i got the name of the csv file
print(os.listdir(data_dir)[0]) #master.csv
#print(type(os.listdir(data_dir)[0]).__name__)

# read the file content using pandas
df = pd.read_csv(data_dir + "/"+os.listdir(data_dir)[0])
#print(df)
print(df.describe())

print(type(df.describe()).__name__) #DataFrame

print(type(df).__name__) #DataFrame


#To delete the unnecessary columns in the DataFrame
# HDI for year and generation
print(df.isnull().sum())  # we can see that 19456 rows are missing for HDI for year so it make sense to remove it
df = df.drop(columns=['HDI for year', 'generation','country-year'])

print(df)

#group by 'country' column and sum by 'suicides/100k pop' column
#sum of the years
df_grouped = df.groupby('country')['suicides/100k pop'].sum().reset_index()
#created a .csv file to see them better names grouped_by_year.csv
df_grouped.to_csv('grouped_by_year', sep=',', index=False, encoding='utf-8')

#find the country with the highes suicide rate from 1985 to 2016


# the cod below is the visualisation of sum of the suicides/100k pop for every country between 1985 and 2016
# (same graph i showed you but without the colors)

'''
country_max_suicides = df_grouped.loc[df_grouped['suicides/100k pop'].idxmax()]

# display the result
print(country_max_suicides)


df_sorted=df_grouped.sort_values(by='suicides/100k pop', ascending=False)
print(df_sorted)

#visualisation of the results
plt.figure(figsize=(15, 10))
plt.bar(df_sorted['country'], df_sorted['suicides/100k pop'], color='skyblue')
plt.xlabel('Country')
plt.ylabel('Suicides per 100k Population')
plt.title('Total Suicides per 100k Population by Country')
plt.xticks(rotation=90) #  to maintain the readabilit,writes country names upright
plt.tight_layout()
plt.show()
'''



# to get all unique country names
country_names_list=df['country'].unique()
print(country_names_list)
#print(len(country_names_list)) #101


#below this i worked with the other dataset the cia one to
#cluster them with their continent and to get their religion

# function to get country data by GitHub code
# https://github.com/factbook/factbook.json
#If you go to this link you will see. In Github, the countries are separated according to their continents into the files
# and each country is given a two-letter code and the files are named accordingly.
# For example, I made an example for Germany below.

# function to get country data by GitHub code
def get_country_data(continent, country_code):
    url = f"https://raw.githubusercontent.com/factbook/factbook.json/master/{continent}/{country_code}.json"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to fetch data")
        return None


# example: data for Germany (gm.json) in Europe
continent = "europe"
country_code = "gm"
country_data = get_country_data(continent, country_code)

# everything on lowercase
'''
if country_data:
    print(country_data['People and Society']['Religions'])


print(type(country_data['People and Society']['Religions']).__name__) #dictionary
print(type(country_data['People and Society']['Religions']['text']).__name__) #str
'''
#url of the csv file of country_codes and region (continent) with the name of the country
url = "https://raw.githubusercontent.com/factbook/factbook/master/factbook-codes/data/codes.csv"
response = requests.get(url)
reader=None
reader_list, continents_list, country_codes_list, religions_list = [], [], [], []

if response.status_code == 200:
    text = (line.decode('utf-8') for line in response.iter_lines())
    #when I didn't do this I was getting the following error:
    # _csv.Error: iterator should return strings, not bytes (the file should be opened in text mode)

    reader = csv.reader(text, delimiter=',')

    # i append each row i read on a list
    #csv file contains 0. index the two-letter country code
    # 1. index the country name
    # 3. index the continent of the country
    for row in reader:
        #print(row)
        reader_list.append(row)

# i was not getting any values for the following four countries
# due to differences in their naming between the two datasets.
#Therefore, I had to hardcode and manually change it myself  :,)  ups 
def continent_name_fix_for_4_countries(country_name):
    if(country_name=='Czech Republic'):
        return 'Czechia'
    elif(country_name=='Russian Federation'):
        return 'Russia'
    elif (country_name == 'Saint Vincent and Grenadines'):
        return 'Saint Vincent and the Grenadines'
    else:
        return country_name

# function for finding continent name for the given country
# again hardcoded republic of korea because in the dataset sount and north korea were handelt as two contries
def find_cont_name(country_name):
    continent = " "
    if country_name == "Republic of Korea":
        return "east & southeast asia"
    for row in reader_list:
        if row[1].split(',')[0] == country_name:
            continent = row[3].lower();
    return  continent

# finding country code given in the GitHub repository
def find_count_code (country_name):
    count_code = " "
    for row in reader_list:
        if row[1].split(',')[0] == country_name:
            count_code = row[0];
    return  count_code

# the csv file and the repository name were a little different i fixed it in order to make it as if it was
# on the path for the repository
#to fix the continent name as in the Github Directory
def fix_continent_name(continent):
    result=continent
    if continent =='central america and caribbean':
        result='central-america-n-caribbean'
    elif continent == 'east & southeast asia':
        result ='east-n-southeast-asia'
    elif len(continent.split(" "))==2:
         result=continent.split(" ")[0]+"-"+continent.split(" ")[1]
    return result


i=0
for country_name in country_names_list:
    country_name=continent_name_fix_for_4_countries(country_name)
    religion = ""
    continent=fix_continent_name(find_cont_name(country_name))
    country_code = find_count_code(country_name)
    country_data = get_country_data(continent, country_code)
    if country_data != None:
        religion = country_data['People and Society']['Religions']['text']
    else :
        print("Failed for the country ", country_name)
    continents_list.insert(i,continent)
    country_codes_list.insert(i,country_code)
    religions_list.insert(i,religion)
    i+=1

#print(len(continents_list))


#print(type(len(country_name)-1).__name__)
print(reader_list)
print(continents_list)
print(country_codes_list)
print(religions_list)





# Add the continent to the dataFrame

if len(continents_list) != len(df_grouped):
    raise ValueError("The lengths of the list does not match the number of rows the dataframe")
# add the continent list as a new column
df_grouped['Continent'] = continents_list
# save the updated DataFrame to a CSV file
df_grouped.to_csv('grouped_by_year_with_continents.csv', sep=',', index=False, encoding='utf-8')


# THE REST IS FOR THE VISUALISATION

# sort the DataFrame in descending order based on the 'suicides/100k pop' column
df_sorted_with_continent = df_grouped.sort_values(by='suicides/100k pop', ascending=False)
print(df_sorted_with_continent)

# create a color map for continents
# first, get a list of unique continents from the sorted DataFrame
continents = df_sorted_with_continent['Continent'].unique()
# initialize an empty dictionary to store the color map
color_map = {}
# iterate over the unique continents and assign a color from the 'tab10' colormap
for i, continent in enumerate(continents):
    color_map[continent] = plt.cm.tab10(i)

# visualization of the results
# set the size of the figure
plt.figure(figsize=(15, 10))
# create a bar plot with countries on the x-axis and suicides per 100k population on the y-axis
# the color of each bar is determined by the continent of the corresponding country
bars = plt.bar(df_sorted_with_continent['country'], df_sorted_with_continent['suicides/100k pop'],
               color=[color_map[continent] for continent in df_sorted_with_continent['Continent']])

# add a legend for the continents
# create a list of handles (rectangles) with the corresponding colors for each continent
handles = [plt.Rectangle((0,0),1,1, color=color_map[continent]) for continent in continents]
# add the legend to the plot with the title 'Continents'
plt.legend(handles, continents, title='Continents')

# add labels and title to the plot
plt.xlabel('Country')
plt.ylabel('Suicides per 100k Population')
plt.title('Total Suicides per 100k Population by Country')
# rotate the x-axis labels (country names) to vertical for better readability
plt.xticks(rotation=90)
# adjust the layout to make sure everything fits without overlapping
plt.tight_layout()
# display the plot
plt.show()