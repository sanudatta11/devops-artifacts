CREATE EXTERNAL TABLE `waf_logs`(
  `timestamp` bigint,
  `formatversion` int,
  `webaclid` string,
  `terminatingruleid` string,
  `terminatingruletype` string,
  `action` string,
  `httpsourcename` string,
  `httpsourceid` string,
  `rulegrouplist` array<string>,
  `ratebasedrulelist` array<
                      struct<
                        ratebasedruleid:string,
                        limitkey:string,
                        maxrateallowed:int
                            >
                           >,
  `nonterminatingmatchingrules` array<
                                struct<
                                  ruleid:string,
                                  action:string
                                      >
                                     >,
  `httprequest` struct<
                      clientip:string,
                      country:string,
                      headers:array<
                              struct<
                                name:string,
                                value:string
                                    >
                                   >,
                      uri:string,
                      args:string,
                      httpversion:string,
                      httpmethod:string,
                      requestid:string
                      > 
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
 'paths'='action,formatVersion,httpRequest,httpSourceId,httpSourceName,nonTerminatingMatchingRules,rateBasedRuleList,ruleGroupList,terminatingRuleId,terminatingRuleType,timestamp,webaclId')
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://athenawaflogs/WebACL/'