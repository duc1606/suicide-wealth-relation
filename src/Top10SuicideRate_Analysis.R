# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:50.486964Z","iopub.execute_input":"2024-07-17T13:01:50.488952Z","iopub.status.idle":"2024-07-17T13:01:51.209527Z"}}
# Benötigte Bibliotheken laden
library(dplyr)
library(ggplot2)
library(readr)

# Datei einlesen
filename <- "csv_files/master.csv"
df <- read_csv(filename)

# Spaltennamen anpassen
colnames(df) <- gsub("suicides/100k pop", "suicides_pop", colnames(df))
colnames(df) <- gsub("HDI for year", "HDI_for_year", colnames(df))
colnames(df) <- gsub(" gdp_for_year \\(\\$\\) ", "gdp_for_year", colnames(df))
colnames(df) <- gsub(" gdp_per_capita \\(\\$\\)", "gdp_per_capita", colnames(df))
colnames(df) <- gsub("gdp_per_capita \\(\\$\\)", "gdp_per_capita", colnames(df))

# Länderbezeichnungen anpassen
df <- df %>%
  mutate(country = recode(country, 
                          "Republic of Korea" = "Korea, Republic of",
                          "Czech Republic" = "Czechia",
                          "Macau" = "Macao",
                          "Saint Vincent and Grenadines" = "Saint Vincent and the Grenadines"))
df <- df %>%
  group_by(country) %>%
  filter(n_distinct(year) >= 20) %>%
  ungroup()

# Suizidanzahlen und Population gruppieren und summieren
df_suino <- df %>% group_by(country, year) %>% summarise(suicides_no = sum(suicides_no))
df_pop <- df %>% group_by(country, year) %>% summarise(population = sum(population))

# Verhältnisse berechnen
df_total <- df_suino %>%
  left_join(df_pop, by = c("country", "year")) %>%
  mutate(suicide_ratio = (suicides_no / population) * 100) %>%
  arrange(country, year)

# Durchschnittliche Suizidraten pro Land berechnen
country_dict <- df_total %>%
  group_by(country) %>%
  summarise(mean_suicide_ratio = mean(suicide_ratio, na.rm = TRUE)) %>%
  arrange(desc(mean_suicide_ratio))

country_list <- country_dict$country
country_suicide <- country_dict$mean_suicide_ratio



# Zeitliche Entwicklung der Suizidraten für die Top 10 Länder
top_10_countries <- head(country_list, 10)
df_top_10 <- df_total %>% filter(country %in% top_10_countries)

ggplot(df_top_10, aes(x = year, y = suicide_ratio, color = country)) +
  geom_line() +
  geom_point() +
  xlab("Year") +
  ylab("Ratio of Suicide") +
  ggtitle("Suicide Rate Over Time for Top 10 Countries") +
  theme_minimal()


# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:51.213548Z","iopub.execute_input":"2024-07-17T13:01:51.215624Z","iopub.status.idle":"2024-07-17T13:01:51.736562Z"}}
# Durchschnittliches BIP pro Kopf gruppieren
df_gdp <- df %>%
  group_by(country, year) %>%
  summarise(gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE)) %>%
  arrange(country, year)

# Zeitliche Entwicklung des BIP pro Kopf für die Top 10 Länder
df_gdp_top_10 <- df_gdp %>% filter(country %in% top_10_countries)

ggplot(df_gdp_top_10, aes(x = year, y = gdp_per_capita, color = country)) +
  geom_line() +
  geom_point() +
  xlab("Year") +
  ylab("GDP per Capita") +
  ggtitle("GDP per Capita Over Time for Top 10 Countries") +
  theme_minimal()


# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:51.739566Z","iopub.execute_input":"2024-07-17T13:01:51.741122Z","iopub.status.idle":"2024-07-17T13:01:52.420485Z"}}
# Benötigte Bibliotheken laden
library(ggplot2)
library(dplyr)

# GDP pro Kopf und Suizidraten für die Top 10 Länder kombinieren
df_gdp_total <- df_gdp %>%
  inner_join(df_total, by = c("country", "year"))

df_gdp_total_top_10 <- df_gdp_total %>%
  filter(country %in% top_10_countries)

# Scatterplot mit Regressionslinien erstellen
ggplot(df_gdp_total_top_10, aes(x = gdp_per_capita, y = suicide_ratio, color = country)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  scale_y_continuous(limits = c(0, 0.06)) +
  xlim(0, NA) +
  labs(x = "GDP per Capita", y = "Ratio of Suicides", title = "GDP per Capita vs Ratio of Suicides for Top 10 Countries") +
  theme_minimal() +
  theme(legend.position = "right")


# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:52.423414Z","iopub.execute_input":"2024-07-17T13:01:52.424933Z","iopub.status.idle":"2024-07-17T13:01:52.467320Z"}}
# Korrelation zwischen BIP pro Kopf und Suizidrate für jedes Land berechnen
correlation_df <- df_gdp_total %>%
  group_by(country) %>%
  summarise(correlation = cor(gdp_per_capita, suicide_ratio, use = "complete.obs")) %>%
  arrange(desc(correlation))

# Ergebnis anzeigen
print(correlation_df)


# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:52.470292Z","iopub.execute_input":"2024-07-17T13:01:52.471914Z","iopub.status.idle":"2024-07-17T13:01:52.848746Z"}}
# Plot der Korrelationskoeffizienten mit Farben nach "YlOrRd"
ggplot(data = correlation_df) +
  aes(x = reorder(country, correlation), y = correlation, fill = correlation) + # reorder countries based on correlation
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "yellow", high = "red") +  # Farbpalette "YlOrRd"
  labs(x = "Countries", y = "Correlation Coefficient", title = "Correlation Coefficient") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6))

# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:01:52.851622Z","iopub.execute_input":"2024-07-17T13:01:52.853112Z","iopub.status.idle":"2024-07-17T13:01:53.228437Z"}}
library(ggplot2)
library(dplyr)

# Annahme: `correlation_df` ist bereits vorhanden und sortiert

# Plot der Korrelationskoeffizienten mit Farben nach "YlOrRd"
ggplot(data = correlation_df, aes(x = reorder(country, correlation), y = correlation, fill = correlation)) +
  geom_bar(stat = "identity") +  # Balkenbreite anpassen
  scale_fill_gradient(palette = "YlOrRd", direction = 1) +  # Farbpalette "YlOrRd"
  labs(x = "Countries", y = "Correlation Coefficient", title = "Correlation Coefficient") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6),  # Text auf der x-Achse drehen und verkleinern
        plot.title = element_text(hjust = 0.5),  # Titel zentrieren
        panel.grid.major.x = element_blank(),  # Gitterlinien auf der x-Achse entfernen
        panel.spacing.x = unit(1, "cm"))  # Abstand zwischen den Balken vergrößern


# %% [code] {"execution":{"iopub.status.busy":"2024-07-17T13:10:46.212047Z","iopub.execute_input":"2024-07-17T13:10:46.213719Z","iopub.status.idle":"2024-07-17T13:10:46.628249Z"}}
library(ggplot2)
library(dplyr)

# Annahme: `correlation_df` ist bereits vorhanden und sortiert

# Plot der Korrelationskoeffizienten mit Farben nach "YlOrRd" und breiterem Layout
ggplot(data = correlation_df, aes(x = reorder(country, correlation), y = correlation, fill = correlation)) +
  geom_bar(stat = "identity", width = 0.7) +  # Balkenbreite anpassen
  scale_fill_gradient(low = "#FFFFCC", high = "#800000", na.value = "grey50") +  # Farbpalette "YlOrRd"
  labs(x = "Countries", y = "Correlation Coefficient", title = "Correlation Coefficient") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, size = 6),  # Text auf der x-Achse drehen und verkleinern
        plot.title = element_text(hjust = 0.5),  # Titel zentrieren
        panel.grid.major.x = element_blank(),  # Gitterlinien auf der x-Achse entfernen
        plot.width = unit(15, "cm"))  # Breite des Plots anpassen


# %% [code]
