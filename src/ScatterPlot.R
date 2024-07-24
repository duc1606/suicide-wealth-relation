#setup
library('tidyverse')
suicide_rate<- read.csv('csv_files/master.csv')

#columns were labeled incorrectly
suicide_rate <- rename(suicide_rate, gdp_for_year = gdp_for_year...., gdp_per_capita = gdp_per_capita....,  suicides_100k_pop = suicides.100k.pop)


#tidy data
suicide_rate_tidy <- select(suicide_rate, country, year, suicides_no, population, suicides_100k_pop, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- group_by(suicide_rate_tidy, country, year, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- summarise(suicide_rate_tidy, suicides_no = sum(suicides_no), population = sum(population), suicides_100k_pop = (sum(suicides_no)/sum(population)) * 100000)

#number of years represented
number_of_occurrences <- group_by(suicide_rate_tidy, country)
number_of_occurrences <- summarise(number_of_occurrences, Number_of_Years = n_distinct(year))

#merge to delete out every country with less than 20 years of data
suicide_rate_tidy <- merge(suicide_rate_tidy, number_of_occurrences)
suicide_rate_tidy <- filter(suicide_rate_tidy, Number_of_Years > 19)


#getting mean for the first general visualization of gdp to suicide_number_100k
all_countries_mean <- group_by(suicide_rate_tidy, country)
all_countries_mean <- summarise(all_countries_mean, gdp_per_capita_avg = mean(gdp_per_capita), suicides_no_avg = mean(suicides_no), suicdes_no_sum = sum(suicides_no), suicide_100k_pop_avg = mean(suicides_100k_pop))



#visualization (could be divided by continents for better plot)
ggplot(data = all_countries_mean) +
  aes(x = gdp_per_capita_avg, y = suicide_100k_pop_avg, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Number of Suicides per 100k Population in relation to GDP",
       x = "GDP per capita",
       y = "suicides per 100k Population") +
  theme(legend.position = "none")






# ggplot(all_countries_mean, aes(x = gdp_per_capita_avg, y = suicide_100k_pop_avg, col = country)) +
#   geom_point() +
#   geom_smooth(method = "lm", aes(group = 1)) +
#   scale_x_continuous(labels=scales::dollar_format(prefix="$"), breaks = seq(0, 70000, 10000)) +
#   labs(title = "Correlation between GDP (per capita) and Suicides per 100k",
#        subtitle = "Plot with high CooksD countries removed (5/93 total)",
#        x = "GDP (per capita)",
#        y = "Suicides per 100k",
#        col = "Continent") +
#   theme(legend.position = "none")