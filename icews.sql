-- find icews data appropriate for classifying mids
show tables;
-- +------------------------------------+
-- | Tables_in_event_data               |
-- +------------------------------------+
-- | actorfilter                        |
-- | actorfilter_countries              |
-- | actorfilter_dict_sectors           |
-- | actorfilter_selections             |
-- | altnames                           |
-- | bad_serif_events                   |
-- | badevents                          |
-- | badstories                         |
-- | cocom_actor_mappings               |
-- | cocom_regions                      |
-- | cocoms                             |
-- | countries                          |
-- | country_info                       |
-- | countrynamechange                  |
-- | dataparam_events_mapping           |
-- | dataparameters                     |
-- | dataparametersearch                |
-- | dataparametersearch_countries      |
-- | dataparametersearch_dataparameters |
-- | dataparametersearch_parameters     |
-- | datapoints                         |
-- | datapoints_change_annotations      |
-- | datapoints_change_log              |
-- | datasources                        |
-- | dict_actgrp_dict_actnodes          |
-- | dict_actor_agent_mappings          |
-- | dict_actorgroups                   |
-- | dict_actorgroups_dict_actors       |
-- | dict_actorlinks                    |
-- | dict_actornodes                    |
-- | dict_actorpatterns                 |
-- | dict_actors                        |
-- | dict_agent_sector_mappings         |
-- | dict_agentpatterns                 |
-- | dict_agents                        |
-- | dict_etcons_et_mappings            |
-- | dict_eventqueries                  |
-- | dict_eventquery_method_types       |
-- | dict_eventquery_methods            |
-- | dict_eventqueryconstraints         |
-- | dict_seccons_sec_mappings          |
-- | dict_sector_actor_mappings         |
-- | dict_sector_frequencies            |
-- | dict_sector_mappings               |
-- | dict_sector_types                  |
-- | dict_sectors                       |
-- | event_source_country_mappings      |
-- | event_source_sector_mappings       |
-- | event_target_country_mappings      |
-- | event_target_sector_mappings       |
-- | eventcoders                        |
-- | eventdatafilter                    |
-- | events                             |
-- | eventtypefilter                    |
-- | eventtypefilter_eventtypes         |
-- | eventtypegroups                    |
-- | eventtypegroups_eventtypes         |
-- | eventtypes                         |
-- | eventverbs                         |
-- | geonames                           |
-- | geonames_specificity_levels        |
-- | gtds_annotations                   |
-- | gtds_annotations_mapping           |
-- | intervals                          |
-- | locations                          |
-- | parametertypes                     |
-- | publisher_mappings                 |
-- | publisher_types                    |
-- | publisherfilter                    |
-- | publisherfilter_selections         |
-- | publishers                         |
-- | publishertypefilter                |
-- | publishertypefilter_selections     |
-- | scales                             |
-- | sentences                          |
-- | serif_events                       |
-- | simple_badevents                   |
-- | simple_events                      |
-- | stories                            |
-- | stories_story_filter_expressions   |
-- | story_filter_expressions           |
-- | story_filters                      |
-- | suggestedactors                    |
-- | verbs                              |
-- | viewed_events                      |
-- +------------------------------------+
-- 85 rows in set (0.00 sec)

--# datapoints
select * from datapoints order by countryid desc limit 10;
select * from datapoints where number_value > 5 order by countryid asc limit 10;
select * from datapoints where number_value > 5 order by value_date asc limit 10;

--# eventcoders
select column_name from information_schema.columns where table_name='eventcoders';
select * from eventcoders order by ID desc limit 10;

--# events
select column_name from information_schema.columns where table_name='events';
select * from events order by event_date desc limit 10;
-- good stuff here, has to be matched with other tables

--# scales
select column_name from information_schema.columns where table_name='scales';
select * from scales limit 10;

--# sentences
select * from sentences limit 10;

--# serif_events
select * from serif_events limit 10;


--# simple_events
select column_name from information_schema.columns where table_name='simple_events';
select * from simple_events order by event_date asc limit 10;
-- eight events in 1970, next in 1991
select * from simple_events order by event_date desc limit 10;
-- goes up to 2013-12-30
SELECT COUNT(*) FROM simple_events;
-- 18mm rows



--# stories
select column_name from information_schema.columns where table_name='stories';
select * from stories limit 1;


--# getting data out
select * from countries limit 10;
select * from eventtypes limit 10;


--# can we get all this in a nice csv? -- requires write access!!!
-- SELECT * INTO OUTFILE '~/events.csv'
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- ESCAPED BY '\\'
-- LINES TERMINATED BY '\n'
-- FROM simple_events WHERE 1 LIMIT 10;

-- SELECT * INTO OUTFILE '/Users/mattdickenson/events.csv'
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- ESCAPED BY '\\'
-- LINES TERMINATED BY '\n'
-- FROM simple_events WHERE 1 LIMIT 10;

-- create table report engine=CSV select * from simple_events;