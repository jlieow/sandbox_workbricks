# Person A

Person A is a self-sufficient data engineer in Group A that requires the following security restrictions:

1. Can use and run queries on at least one SQL warehouse.
2. Can create “classic” clusters in dedicated mode and with the maximum number of workers set to 3.
3. They have a group workspace folder to collaborate with others, and have the ability to read and write files in it.
4. They can use their team's sandbox catalog that they can create new schemas, tables, and other objects in - however they can’t delete the catalog.
5. They can create and run jobs. 
6. They can use serverless compute with a budget policy that has a single tag with key t_costcenter and value of groupa.

# Person B

Person B is a data analyst in Group B that requires the following:

They cannot create classic clusters, but they can use a single, shared cluster that was already created for them that they can’t delete it. 

They can use and run queries on at least one SQL warehouse.

They can use serverless compute with a budget policy that has a single tag with key t_costcenter and value of groupb.

They can read one specific table in Group A’s catalog but they can not write to or modify anything. 