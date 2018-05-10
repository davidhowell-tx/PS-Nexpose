## Asset
Name | API URI | Commandlet
--- | --- | ---
Assets | GET /api/3/assets | `Get-NPAsset`
Assets | POST /api/3/sites/{id}/assets |
Asset Search | POST /api/3/assets/search |
Asset | GET /api/3/assets/{id} | `Get-NPAsset -ID {id}`
Asset | DELETE /api/3/assets/{id} |
Asset Databases | GET /api/3/assets/{id}/databases | `Get-NPAsset -ID {id} -Properties Databases`<br>`Get-NPAsset -Properties Databases`<br>`Get-NPAsset -Properties All`
Asset Files | GET /api/3/assets/{id}/files | `Get-NPAsset -ID {id} -Properties Files`<br>`Get-NPAsset -Properties Files`<br>`Get-NPAsset -Properties All`
Asset Services | GET /api/3/assets/{id}/services | `Get-NPAsset -ID {id} -Properties Services`<br>`Get-NPAsset -Properties Services`<br>`Get-NPAsset -Properties All`
Asset Service | GET /api/3/assets/{id}/services/<br>{protocol}/{port} | 
Asset Service Configurations | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/configurations |
Asset Service Databases | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/databases |
Asset Service User Groups | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/user_groups |
Asset Service Users | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/users |
Asset Service Web Applications | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/web_applications |
Asset Service Web Application | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/web_applications/<br>{webApplicationId} |
Asset Software | GET /api/3/assets/{id}/software | `Get-NPAsset -ID {id} -Properties Software`<br>`Get-NPAsset -Properties Software`<br>`Get-NPAsset -Properties All`
Asset Tags | GET /api/3/assets/{id}/tags | `Get-NPAsset -ID {id} -Properties Tags`<br>`Get-NPAsset -Properties Tags`<br>`Get-NPAsset -Properties All`
Asset Tag | PUT /api/3/assets/{id}/tags/{tagId} | 
Asset Tag | DELETE /api/3/assets/{id}/tags/{tagId} |
Asset User Groups | GET /api/3/assets/{id}/user_groups | `Get-NPAsset -ID {id} -Properties 'User Groups'`<br>`Get-NPAsset -Properties 'User Groups'`<br>`Get-NPAsset -Properties All`
Asset Users | GET /api/3/assets/{id}/users | `Get-NPAsset -ID {id} -Properties Users`<br>`Get-NPAsset -Properties Users`<br>`Get-NPAsset -Properties All`
Operating Systems | GET /api/3/operating_systems | `Get-NPOperatingSystem`
Operating System | GET /api/3/operating_systems/{id} | `Get-NPOperatingSystem -ID {id}`
Software | GET /api/3/software | `Get-NPSoftware`
Software | GET /api/3/software/{id} | `Get-NPSoftware -ID {id}`

## Asset Discovery
Name | API URI | Commandlet
--- | --- | ---
Discovery Connections | GET /api/3/discovery_connections | `Get-NPDiscoveryConnection`
Discovery Connection | GET /api/3/discovery_connections/{id} | `Get-NPDiscoveryConnection -ID {id}`
Discovery Connection Reconnect | POST /api/3/discovery_connections/{id}/<br>connect | 
Sonar Queries | GET /api/3/sonar_queries | `Get-NPSonarQuery`
Sonar Queries | POST /api/3/sonar_queries |
Sonar Queries | POST /api/3/sonar_queries/search |
Sonar Query | GET /api/3/sonar_queries/{id} | `Get-NPSonarQuery -ID {id}`
Sonar Query | PUT /api/3/sonar_queries/{id} |
Sonar Query | DELETE /api/3/sonar_queries/{id} |
Sonar Query Assets | GET /api/3/sonar_queries/{id}/assets |

## Asset Group
Name | API URI | Commandlet
--- | --- | ---
Asset Groups | GET /api/3/asset_groups | `Get-NPAssetGroup`
Asset Groups | POST /api/3/asset_groups |
Asset Group | GET /api/3/asset_groups/{id} | `Get-NPAssetGroup -ID {id}`
Asset Group | PUT /api/3/asset_groups/{id} |
Asset Group | DELETE /api/3/asset_groups/{id} |
Asset Group Assets | GET /api/3/asset_groups/{id}/assets | `Get-NPAssetGroup -ID {id} -Properties 'Asset Group Assets'`<br>`Get-NPAssetGroup -Properties 'Asset Group Assets'`<br>`Get-NPAssetGroup -Properties All`
Asset Group Assets | PUT /api/3/asset_groups/{id}/assets |
Asset Group Assets | DELETE /api/3/asset_groups/{id}/assets |
Asset Group Asset | PUT /api/3/asset_groups/{id}/assets/{assetId} |
Asset Group Asset | DELETE /api/3/asset_groups/{id}/assets/{assetId} |
Asset Group Search Criteria | GET /api/3/asset_groups/{id}/search_criteria |
Asset Group Search Criteria | PUT /api/3/asset_groups/{id}/search_criteria |
Asset Group Tags | GET /api/3/asset_groups/{id}/tags | `Get-NPAssetGroup -ID {id} -Properties 'Asset Group Tags'`<br>`Get-NPAssetGroup -Properties 'Asset Group Tags'`<br>`Get-NPAssetGroup -Properties All`
Asset Group Tags | PUT /api/3/asset_groups/{id}/tags |
Asset Group Tags | DELETE /api/3/asset_groups/{id}/tags |
Asset Group Tag | PUT /api/3/asset_groups/{id}/tags/{tagId} |
Asset Group Tag | DELETE /api/3/asset_groups/{id}/tags/{tagId} |
Asset Group Users | GET /api/3/asset_groups/{id}/users | `Get-NPAssetGroup -ID {id} -Properties 'Asset Group Users'`<br>`Get-NPAssetGroup -Properties 'Asset Group Users'`<br>`Get-NPAssetGroup -Properties All`
Asset Group Users | PUT /api/3/asset_groups/{id}/users |
Asset Group User | PUT /api/3/asset_groups/{id}/users/{userId} |
Asset Group User | DELETE /api/3/asset_groups/{id}/users/{userId} |

## Credential
Name | API URI | Commandlet
--- | --- | ---
Shared Credentials | GET /api/3/shared_credentials | `Get-NPSharedCredential`
Shared Credentials | POST /api/3/shared_credentials | 
Shared Credentials | DELETE /api/3/shared_credentials | 
Shared Credential | GET /api/3/shared_credentials/{id} | `Get-NPSharedCredential -ID {id}`
Shared Credential | PUT /api/3/shared_credentials/{id} |
Shared Credential | DELETE /api/3/shared_credentials/{id} |

## Policy
Name | API URI | Commandlet
--- | --- | ---
Policies For Asset | GET /api/3/assets/{assetId}<br>/policies |
Policy Rules or Groups Directly Under Policy for Asset | GET /api/3/assets/{assetId}<br>/policies/{policyId}/children |
Policy Rules or Groups Directly Under Policy Group for Asset | GET /api/3/assets/{assetId}<br>/policies/{policyId}/groups<br>/{groupId}/children |
Policy Rules Under Policy Group For Asset | GET /api/3/assets/{assetId}<br>/policies/{policyId}/groups<br>/{groupId}/rules |
Policy Rules For Asset | GET /api/3/assets/{assetId}<br>/policies/{policyId}/rules | 
Policies | GET /api/3/policies | `Get-NPPolicy`
Policy Rules or Groups Directly Under Policy | GET /api/3/policies/{id}/children | 
Policy | GET /api/3/policies/{policyId} | `Get-NPPolicy -ID {policyId}`
Policy Asset Results | GET /api/3/policies/{policyId}/assets | `Get-NPPolicy -ID {policyId} -Properties 'Policy Asset Results'`<br>`Get-NPPolicy -ID {policyId} -Properties All`<br>`Get-NPPolicy -Properties 'Policy Asset Results'`<br>`Get-NPPolicy -Properties All`
Policy Asset Result | GET /api/3/policies/{policyId}/assets/{assetId} |

TODO: Finish table

## Policy Override
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Remediation
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Report
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Scan
Name | API URI | Commandlet
--- | --- | ---
Scans | GET /api/3/scans | `Get-NPScan`
Scan | GET /api/3/scans/{id} | `Get-NPScan -ID {id}`
Scan Status | POST /api/3/scans/{id}/{status} | 
Site Scans | GET /api/3/sites/{id}/scans | `Get-NPScan -SiteID {siteId}`
Site Scans | POST /api/3/sites/{id}/scans | 

## Scan Engine
Name | API URI | Commandlet
--- | --- | ---
Engine Pools | GET /api/3/scan_engine_pools | `Get-NPScanEnginePool`

TODO: Finish Table

## Scan Template
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Site
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Tag
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## User
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Vulnerability
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Vulnerability Check
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table

## Vulnerability Exception
Name | API URI | Commandlet
--- | --- | ---

TODO: Finish Table
