# Load necessary libraries
library('tidyverse')

# Read the CSV file containing suicide rate data
suicide_rate <- read.csv('src/csv_files/master.csv')

# Rename columns that were labeled incorrectly
suicide_rate <- rename(suicide_rate, 
                       gdp_for_year = gdp_for_year...., 
                       gdp_per_capita = gdp_per_capita....,  
                       suicides_100k_pop = suicides.100k.pop)

# Tidy the suicide_rate data by selecting relevant columns
suicide_rate_tidy <- select(suicide_rate, country, year, suicides_no, population, suicides_100k_pop, gdp_for_year, gdp_per_capita)
# Group by relevant columns
suicide_rate_tidy <- group_by(suicide_rate_tidy, country, year, gdp_for_year, gdp_per_capita)
# Summarize the data
suicide_rate_tidy <- summarise(suicide_rate_tidy, 
                               suicides_no = sum(suicides_no), 
                               population = sum(population), 
                               suicides_100k_pop = (sum(suicides_no)/sum(population)) * 100000)

# Calculate the number of years represented for each country
number_of_occurrences <- group_by(suicide_rate_tidy, country)
number_of_occurrences <- summarise(number_of_occurrences, Number_of_Years = n_distinct(year))

# Merge to filter out countries with less than 20 years of data
suicide_rate_tidy <- merge(suicide_rate_tidy, number_of_occurrences)
suicide_rate_tidy <- filter(suicide_rate_tidy, Number_of_Years > 19)

# Calculate means for general visualization of GDP and suicide rate per 100k
all_countries_mean <- group_by(suicide_rate_tidy, country)
all_countries_mean <- summarise(all_countries_mean, 
                                gdp_per_capita_avg = mean(gdp_per_capita), 
                                suicides_no_avg = mean(suicides_no), 
                                suicdes_no_sum = sum(suicides_no), 
                                suicide_100k_pop_avg = mean(suicides_100k_pop))

# Visualize the relationship between GDP per capita and suicide rate per 100k population
ggplot(data = all_countries_mean) +
  aes(x = gdp_per_capita_avg, y = suicide_100k_pop_avg, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Number of Suicides per 100k Population in relation to GDP",
       x = "GDP per capita",
       y = "Suicides per 100k Population") +
  theme(legend.position = "none")

