I started writing ARM templates for a basic single webapp with an Azure SQL DB in the backend (to demonstrate my ARM template skills) but felt that the solution lacks scalability, resiliency, security and doesn't do justice as I have been working on ARM templates for few years but not showing off some of the key operations that come out of the box i.e iterations, conditions and nested templates.
So I started expanding my solution and half a day later we have:

3 x WebApps: Deployed multiple instances of webapps using Copy operation. Also linked the webapps with the Azure SQL DB by specifying the connection strings as a nested property. Application insight is enabled on all three webapps to understand the performance and usage.
 
1 x App Service Plan : Used one App Service Plan as all the webapps are in the same region and  standard service plan is sufficient to host multiple web apps with enough dedicated compute resouce assigned plus application insight to autoscale the service plan to maximum of two instances should the CPU usage goes over 80% for 10mins.

1 x Azure SQL Server
1 x Azure SQL DB
Parameter file is coded to use Azure Key Vault for sql admin password that must be either removed or subscriptionid added (I have put xxxx to mask my subid)

1 x Application Gateway with WAF enabled: Using nested template for this deployment. It is also an optional deployment controlled by a boolean parameter that can be turned on or off using true or false in the parameter section. If selected to deploy, a vNet, subnet, public ip will be created along the app gateway. All of the three webapp URLs are passed to the template during deployment to add them to the backendpool of the gateway. Public IP is linked to the frontend configuration of app gateway with httplistener associated to it. httplistener probe is created for app service and linked to the app gateway backend http settings so incoming traffic can be routed to the backend web apps if no threats are detected. App Gateway is created with default rules, firewall is set as enabled and set on detection mode.

High level diagram is added to the repo which shows all the components of the solution (apart from app insight, will add that when I get a chance)
![image](https://github.com/rizzkhan1/repo/blob/master/webSiteSQLDatabaseDesign.png)
