# customerRentalHistory
SQL code for generating the tables necessary to provide a customer rental history and customer status from the provided DVD Rental database. Project for D326: Advanced Data Management

D326 culminates in a final project which asks the student to identify a relevant business question to analyze using the data from the provided DVD Rental Database. The student is tasked with creating data tables and queries to use as a business report, and then streamlining the analysis by creating SQL functions, triggers, and stored procedures.

Below is a summary of my project:

The business report that I have created utilizes data from the provided DVD RENTAL Database to measure and qualify customer rental activity at the hypothetical DVD rental business.  The report draws on data from the ‘customer’ and ‘rental’ tables to associate customers with their respective rental purchases in order to create a history of each customer’s rental dates.

In the detailed table created for this report, the rental history can be used to identify a nominal frequency with which each customer rents DVD’s from the business. In a real-world environment, this data would be useful in analyzing customer rental habits for the consideration of marketing promotions or alternative payment structures, such as memberships. 

The summary table, produced in this report, indicates individual customer activity status based on whether or not the customer has rented any DVD’s in the past three months.  This data could then be used to distribute targeted marketing for inactive customers, in order to provide greater incentive for them to return to, and resume using the DVD rental services. 

It would be beneficial for these reports to be refreshed on a monthly basis. This would enable the business managers to organize marketing efforts on regular intervals that target inactive customers, as well as analyze the effects that these marketing efforts have on customer activity.

Under different project requirements and constraints, I think that it would also be useful to associate information from the ‘film’, ‘category’, and ‘actor’ tables with individual customer rental histories. In order to do this, it may be beneficial to create a table for each individual customer that contains information from these additional tables, regarding that customer’s rental history. This would enable the DVD rental business to provide individually tailored film recommendations for customers based on such things as the customer’s most frequently rented ‘category’ of film, or actors who frequently appear in the films that the customer has rented.  
