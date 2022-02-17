#sei: Missing-data codes: -1.0,99.8,99.9
dfSubset <- gss %>%
    filter(
        !is.na(natcrime), 
        !is.na(class), 
        !is.na(sei),
        class != 'No Class',
        sei >= 0 & sei < 99.8,
        ) %>%
    select(year, class, sei, natcrime, fear) %>%
    droplevels()

q_sei <- quantile(dfSubset$sei, c(1:3)/4)
q_sei

dfSubset <- dfSubset %>%
    mutate(socioeconomic = factor(
        case_when(
            sei <= q_sei[1] ~ '1',
            sei > q_sei[1] & sei <= q_sei[2] ~ '2',
            sei > q_sei[2] & sei <= q_sei[3] ~ '3',
            TRUE ~ '4'
        ),
        labels=c('Lower', 'Lower Middle', 'Upper Middle', 'Upper')
    ) 
    )

dfSubset %>% sample_n(10)

dfclassfear <- dfSubset %>% 
    filter(!is.na(fear)) %>%  
    group_by(class, year, fear) %>%
    summarise(n=n()) %>%
    mutate(proportion = round(100 * n / sum(n), 1)) %>%
    filter(fear=='Yes') %>%
    select(-n, -fear) %>%
    pivot_wider(names_from = class, values_from = proportion)

dfclassyearcrime <- dfSubset %>% 
    group_by(class, year, natcrime) %>%
    summarise(n=n()) %>%
    mutate(proportion = round(100 * n / sum(n), 1)) %>%
    filter(natcrime=='Too Little') %>%
    select(-n, -natcrime) %>%
    rename(Year = year) 

p <- ungroup(dfclassyearcrime) %>%
    pivot_wider(names_from = class, values_from = proportion) %>%
    plot_ly(x=~Year, y=~`Lower Class`, name='Lower Class', type='scatter', mode='lines') %>%
    add_trace(y=~`Working Class`, name='Working Class', mode='lines') %>%
    add_trace(y=~`Middle Class`, name='Middle Class', mode='lines') %>%
    add_trace(y=~`Upper Class`, name='Upper Class', mode='lines') %>% 
    config(displayModeBar = F) %>%
    layout(xaxis=list(fixedrange=T)) 
    
t <- dfclassyearcrime %>%
    pivot_wider(names_from = Year, values_from = proportion) %>%
    kbl() %>% 
    kable_styling(bootstrap_options = c("condensed"))

dfSubset <- dfSubset %>%
    filter(year >= 2000)

plot_ly(dfSubset, x=~class, type='histogram', alpha = 0.6)
plot_ly(dfSubset, x=~socioeconomic, type='histogram', alpha = 0.6)
plot_ly(dfSubset, x=~natcrime, type='histogram', alpha = 0.6)

all = dfSubset %>% 
    group_by(natcrime) %>%
    summarise(n=n()) %>%
    mutate(proportion = round(100 * n / sum(n), 1)) %>%
    mutate(class='All Classes') %>%
    select(-n) %>%
    relocate(class)

dfclasscrime <- dfSubset %>% 
    group_by(class, natcrime) %>%
    summarise(n=n()) %>%
    mutate(proportion = round(100 * n / sum(n), 1)) %>%
    select(-n) %>%
    rbind(all) %>%
    pivot_wider(names_from = class, values_from = proportion) 

#source('http://bit.ly/dasi_inference')
inference(
    y=dfSubset$natcrime, 
    x=dfSubset$class,
    est='proportion', 
    type='ht', 
    method='theoretical', 
    alternative = 'greater', 
    nsim = 100000
    )


dfSubset <- gss %>%
    filter(
        !is.na(natcrime), 
        !is.na(sei)
    ) %>%
    select(sei, natcrime) %>%
    droplevels()

q_sei <- quantile(dfSubset$sei, c(1:3)/4)

dfSubset <- dfSubset %>%
    mutate(socioeconomic = factor(
        case_when(
            sei <= q_sei[1] ~ '1',
            sei > q_sei[1] & sei <= q_sei[2] ~ '2',
            sei > q_sei[2] & sei <= q_sei[3] ~ '3',
            TRUE ~ '4'
        ),
        labels=c('Lower', 'Lower Middle', 'Upper Middle', 'Upper')
    ) 
    )

inference(
    y=dfSubset$natcrime, 
    x=dfSubset$socioeconomic,
    est='proportion', 
    type='ht', 
    method='theoretical', 
    alternative = 'greater', 
    nsim = 100000
)



christian_denoms <- c(
    'Catholic', 
    'Protestant', 
    'Inter-Nondenominational', 
    'Christian', 
    'Orthodox-Christian'
    )

religion <- gss %>%
    filter(
        !is.na(consci), 
        !is.na(attend), 
        !is.na(relig),
        relig != 'Other',
        relig != 'None' | as.numeric(attend) >= 4
        ) %>%
    select(relig, attend, consci) %>%
    mutate(faith = case_when(
        as.character(relig) %in% christian_denoms ~ 'Christian',
        TRUE ~ as.character(relig)
        )
    )

religion %>% 
    group_by(faith) %>%
    summarise(n=n())

religion <- religion %>%
    filter(!(as.character(relig) %in% c('Native American', 'Other Eastern', 'Buddhism', 'Hinduism')))

religion %>% 
    group_by(faith, consci) %>%
    summarise(n=n()) %>%
    mutate(proportion = n / sum(n)) %>%
    select(-n) %>%
    pivot_wider(names_from = consci, values_from = proportion)

religion %>% 
    group_by(faith, consci) %>%
    summarise(n=n()) %>%
    mutate(proportion = n / sum(n)) %>%
    select(-n) %>%
    pivot_wider(names_from = consci, values_from = proportion)

df