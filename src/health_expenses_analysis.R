# Load necessary libraries
library('tidyverse')

# Read the CSV files
suicide_rate <- read.csv('src/csv_files/master.csv')
health_system <- read.csv('src/csv_files/Health_Systems.csv')
# Health system source: https://www.kaggle.com/datasets/danevans/world-bank-wdi-212-health-systems

# Rename columns that were labeled incorrectly
suicide_rate <- rename(suicide_rate, 
                       gdp_for_year = gdp_for_year...., 
                       gdp_per_capita = gdp_per_capita....,  
                       suicides_100k_pop = suicides.100k.pop)

# Tidy the master.csv file by selecting relevant columns
suicide_rate_tidy <- select(suicide_rate, country, year, suicides_no, population, suicides_100k_pop, gdp_for_year, gdp_per_capita)
# Group by relevant columns
suicide_rate_tidy <- group_by(suicide_rate_tidy, country, year, gdp_for_year, gdp_per_capita)
# Summarize the data
suicide_rate_tidy <- summarise(suicide_rate_tidy, 
                               suicides_no = sum(suicides_no), 
                               population = sum(population), 
                               suicides_100k_pop = (sum(suicides_no)/sum(population)) * 100000)

# Calculate the number of years represented in master.csv for each country
number_of_occurrences <- group_by(suicide_rate_tidy, country)
number_of_occurrences <- summarise(number_of_occurrences, Number_of_Years = n_distinct(year))

# Merge to remove countries with less than 20 years of data
suicide_rate_tidy <- merge(suicide_rate_tidy, number_of_occurrences)
suicide_rate_tidy <- filter(suicide_rate_tidy, Number_of_Years > 19)

# Calculate means for general visualization of GDP to suicide rate per 100k
all_countries_mean <- group_by(suicide_rate_tidy, country)
all_countries_mean <- summarise(all_countries_mean, 
                                gdp_per_capita_avg = mean(gdp_per_capita), 
                                suicides_no_avg = mean(suicides_no), 
                                suicdes_no_sum = sum(suicides_no), 
                                suicide_100k_pop_avg = mean(suicides_100k_pop))

# Tidy the health_system.csv file
health_system_tidy <- group_by(health_system, Country_Region)
health_system_tidy <- rename(health_system_tidy, 
                             country = Country_Region, 
                             health_expenses_percentage_gdp = Health_exp_pct_GDP_2016, 
                             health_expenses_per_capita = Health_exp_per_capita_USD_2016)
health_system_tidy <- select(health_system_tidy, country, health_expenses_per_capita, health_expenses_percentage_gdp)

# Calculate correlation coefficient between GDP per capita and suicide rate per 100k for each country
correlation_coef <- group_by(suicide_rate_tidy, country)
correlation_coef <- summarise(correlation_coef, 
                              correlation = cor(gdp_per_capita, suicides_100k_pop, use = 'complete.obs'), 
                              suicides_100k_pop)
correlation_coef <- summarise(correlation_coef, correlation = mean(correlation))

# Merge datasets together
suicide_rate_to_health_system <- merge(health_system_tidy, correlation_coef, by = "country")
scatterplot_health_system_suiciderate <- merge(health_system_tidy, all_countries_mean, by = "country")

# Plot the correlation coefficients to health expenses per capita
ggplot(data = suicide_rate_to_health_system) +
  aes(x = reorder(country, correlation), y = health_expenses_per_capita) +
  geom_bar(stat = "identity", fill = "red") +
  labs(x = "Countries", y = "Health Expenses per Capita", title = "Correlation Coefficient to Health System") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6))

# Uncomment to plot the correlation coefficients to health expenses percentage of GDP
# ggplot(data = suicide_rate_to_health_system) +
#   aes(x = reorder(country, correlation), y = health_expenses_percentage_gdp) +
#   geom_bar(stat = "identity", fill = "blue") +
#   labs(x = "Countries", y = "Health Expenses Percentage of GDP", title = "Correlation Coefficient to Health System") +
#   theme_minimal() +
#   theme(axis.text.x = element_text(angle = 90, size = 6))

# Scatter plot: Health expenses per capita vs. suicide rate per 100k population
ggplot(data = scatterplot_health_system_suiciderate) +
  aes(x = health_expenses_per_capita, y = suicide_100k_pop_avg, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Health System Expenses vs. Suicides per 100k Population",
       x = "Health System Expenses per Capita",
       y = "Suicides per 100k Population Average") +
  theme(legend.position = "none")

# Scatter plot: Health expenses per capita vs. GDP per capita
ggplot(data = scatterplot_health_system_suiciderate) +
  aes(x = health_expenses_per_capita, y = gdp_per_capita_avg, color = country) +
  geom_point(size = 3) +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Health System Expenses vs. GDP per Capita",
       x = "Health System Expenses per Capita",
       y = "GDP per Capita") +
  theme(legend.position = "none")
