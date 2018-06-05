Git API
=======

A read-only JSON API for getting information about your git repos.

Set the `PROJECT_DIR` and the server will handle the rest.

```
GET /repos

[
  {
    "name": "git-api",
    "updated_at": "2018-06-04 22:10:45 -0400"
  }
]

GET /repos/:repo

{
  "branches": [
    "master"
  ],
  "commits": 2,
  "files": [
    {
      "directory": false,
      "name": "README.md",
      "size": 490
    }
  ],
  "readme": "Git API\n=======\nA read-only JSON API...",
  "tags": []
}
```
