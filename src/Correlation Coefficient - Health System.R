
#setup: run: install.packages('reticulate')
library('tidyverse')
suicide_rate <- read.csv('Desktop/Uni/Data Science/suicidewealthcorrelation/src/csv_files/master.csv')
health_system <- read.csv('Desktop/Uni/Data Science/suicidewealthcorrelation/src/csv_files/Health_Systems.csv')
#health system source: https://www.kaggle.com/datasets/danevans/world-bank-wdi-212-health-systems



#columns were labeled incorrectly
suicide_rate <- rename(suicide_rate, gdp_for_year = gdp_for_year...., gdp_per_capita = gdp_per_capita....,  suicides_100k_pop = suicides.100k.pop)


#tidy master.csv
suicide_rate_tidy <- select(suicide_rate, country, year, suicides_no, population, suicides_100k_pop, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- group_by(suicide_rate_tidy, country, year, gdp_for_year, gdp_per_capita)
suicide_rate_tidy <- summarise(suicide_rate_tidy, suicides_no = sum(suicides_no), population = sum(population), suicides_100k_pop = (sum(suicides_no)/sum(population)) * 100000)

#number of years represented in master.csv
number_of_occurrences <- group_by(suicide_rate_tidy, country)
number_of_occurrences <- summarise(number_of_occurrences, Number_of_Years = n_distinct(year))

#merge to delete out every country with less than 20 years of data
suicide_rate_tidy <- merge(suicide_rate_tidy, number_of_occurrences)
suicide_rate_tidy <- filter(suicide_rate_tidy, Number_of_Years > 19)


#getting mean for the first general visualization of gdp to suicide_number_100k
all_countries_mean <- group_by(suicide_rate_tidy, country)
all_countries_mean <- summarise(all_countries_mean, gdp_per_capita_avg = mean(gdp_per_capita), suicides_no_avg = mean(suicides_no), suicdes_no_sum = sum(suicides_no), suicide_100k_pop_avg = mean(suicides_100k_pop))


#tidy health_system.csv
health_system_tidy <- group_by(health_system, Country_Region)
health_system_tidy <- rename(health_system_tidy, country = Country_Region, health_expenses_percentage_gdp = Health_exp_pct_GDP_2016, health_expenses_per_capita = Health_exp_per_capita_USD_2016)
health_system_tidy <- select(health_system_tidy, country, health_expenses_per_capita, health_expenses_percentage_gdp)


#calculate correlation coefficient
correlation_coef <- group_by(suicide_rate_tidy, country)
correlation_coef <- summarise(correlation_coef, correlation = cor(gdp_per_capita, suicides_100k_pop, use = 'complete.obs'), suicides_100k_pop)
correlation_coef <- summarise(correlation_coef, correlation = mean(correlation))


#merge datasets together
suicide_rate_to_health_system <- merge(health_system_tidy, correlation_coef, by = "country")
scatterplot_health_system_suiciderate <- merge(health_system_tidy, all_countries_mean, by = "country")



# plot the correlation coefficients to sunshine
ggplot(data = suicide_rate_to_health_system) +
  aes(x = reorder(country, correlation), y = health_expenses_per_capita) +
  geom_bar(stat = "identity", fill = "red") +
  labs(x = "Countries", y = "Health_expenses_per_capita", title = "Correlation Coefficient to Health System") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6))

# ggplot(data = suicide_rate_to_health_system) +
#   aes(x = reorder(country, correlation), y = health_expenses_percentage_gdp) +
#   geom_bar(stat = "identity", fill = "blue") +
#   labs(x = "Countries", y = "Health_expenses_per_capita", title = "Correlation Coefficient to Health System") +
#   theme_minimal() +
#   theme(axis.text.x = element_text(angle = 90, size = 6))

# scatter plot expenses per capita to suicide rate
ggplot(data = scatterplot_health_system_suiciderate) +
  aes(x = health_expenses_per_capita, y = suicide_100k_pop_avg, color = country) +
  geom_point(size = 3) +
  scale_x_log10() +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Health System expenses to suicides per 100k Population",
       x = "Health System Expenses per Capita",
       y = "suicides per 100k Population Average") +
  theme(legend.position = "none")

# scatter plot expenses per capita to gdp per capita
ggplot(data = scatterplot_health_system_suiciderate) +
  aes(x = health_expenses_per_capita, y = gdp_per_capita_avg, color = country) +
  geom_point(size = 3) +
  geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
  labs(title = "Health System expenses to GDP per capita",
       x = "Health SystemExpenses per Capita",
       y = "GDP per capita") +
  theme(legend.position = "none")

# Berechnung des Korrelationskoeffizienten
correlation_coef <- group_by(suicide_rate_tidy, country)
correlation_coef <- summarise(correlation_coef, 
                              correlation = cor(gdp_per_capita, suicides_100k_pop, use = 'complete.obs'), 
                              suicides_100k_pop)
correlation_coef <- summarise(correlation_coef, correlation = mean(correlation))

# Zusammenführen der Datensätze
suicide_rate_to_health_system <- merge(health_system_tidy, correlation_coef, by = "country")
scatterplot_health_system_suiciderate <- merge(health_system_tidy, all_countries_mean, by = "country")

# Plot der Korrelationskoeffizienten mit Farben nach "YlOrRd"
ggplot(data = correlation_coef, aes(x = reorder(country, correlation), y = correlation, fill = correlation)) +
  geom_bar(stat = "identity", width = 0.7) +  # Balkenbreite anpassen
  scale_fill_gradient(low = "yellow", high = "red") +  # Farbpalette "YlOrRd"
  labs(x = "Countries", y = "Correlation Coefficient", title = "Correlation Coefficient") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6),  # Text auf der x-Achse drehen und verkleinern
        plot.title = element_text(hjust = 0.5),  # Titel zentrieren
        panel.grid.major.x = element_blank(),  # Gitterlinien auf der x-Achse entfernen
        panel.spacing.x = unit(1, "cm"))  # Abstand zwischen den Balken vergrößern

# Weitere ggplot-Plots hier einfügen, wenn benötigt



# # scatter plot expenses percantage gdp to suicide rate
# ggplot(data = scatterplot_health_system_suiciderate) +
#   aes(x = health_expenses_percentage_gdp, y = suicide_100k_pop_avg, color = country) +
#   geom_point(size = 3) +
#   geom_text(aes(label = country), vjust = -0.5, hjust = 0.5, size = 3) +
#   labs(title = "Health Expenses to suicides per 100k Population",
#        x = "Health Expenses percantage of GDP",
#        y = "Suicide per 100k Pop") +
#   theme(legend.position = "none")


