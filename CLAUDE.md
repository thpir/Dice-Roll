# Claude Code Guidelines

## Architecture
Before making any code changes, read `architecture.md` to understand the project structure, layer responsibilities, and naming conventions. 

In this project there is quite some legacy code not matching the architecture.md file. For every:
- new implementation of a feature, try to match the architecture provided in the architecture.md file
- changes / fixes in an existing feature, evaluate the workload to refactor the legacy code and advice the human developer prior to editing. Always write tests in the test folder first that encapsulate logic and UI of the legacy code so you can evaluate your refactoring work afterwards. 
