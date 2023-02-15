# TODO List
CRUD api to work with TODO List.

### Structure and behavior description
There is an api to create JWT token:

    POST   /authenticate
    Payload: { email: 'some@email.com', password: 'SomePassword' }

There are CRUD api to work with tasks and subtasks.

Tasks results can be filtered by tags and category this way:
    GET   /tasks?tags=tag1,tag2&category_id=1
