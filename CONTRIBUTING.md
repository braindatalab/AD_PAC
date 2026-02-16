# Contributing to AD_PAC

Thank you for your interest in contributing to the AD_PAC project! This document provides guidelines for contributing to this repository.

## How to Contribute

### Reporting Issues

If you encounter bugs or have suggestions for improvements:

1. Check if the issue already exists in the [Issues](https://github.com/braindatalab/AD_PAC/issues) section
2. If not, create a new issue with:
   - A clear, descriptive title
   - Detailed description of the problem or suggestion
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior
   - Your environment (MATLAB version, OS, toolbox versions)
   - Relevant code snippets or error messages

### Submitting Changes

1. **Fork the repository** to your GitHub account

2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/AD_PAC.git
   cd AD_PAC
   ```

3. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

4. **Make your changes**:
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if you change functionality
   - Test your changes thoroughly

5. **Commit your changes** with clear, descriptive messages:
   ```bash
   git add .
   git commit -m "Add feature: brief description"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Submit a Pull Request** (PR):
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your fork and branch
   - Provide a clear description of your changes
   - Reference any related issues

## Code Guidelines

### MATLAB Code Style

- Use clear, descriptive variable names
- Add comments for complex operations
- Follow MATLAB naming conventions:
  - Functions: `camelCase` or `snake_case`
  - Variables: `camelCase` or `snake_case`
  - Constants: `UPPER_CASE`
- Include function documentation headers:
  ```matlab
  function output = myFunction(input1, input2)
  % MYFUNCTION Brief description
  %
  % Detailed description of what the function does
  %
  % Input:
  %   input1 - Description of first input
  %   input2 - Description of second input
  %
  % Output:
  %   output - Description of output
  %
  % Example:
  %   result = myFunction(data, params);
  
  % Function implementation
  end
  ```

### Documentation

- Update README files if you add new features
- Document new functions and scripts
- Include usage examples for new functionality
- Update CITATION.md if you add methods that should be cited

### Testing

- Test your changes with sample data
- Ensure backward compatibility when possible
- Document any breaking changes clearly
- Verify that existing functionality still works

## Types of Contributions

### Bug Fixes

- Fix incorrect calculations
- Resolve errors or crashes
- Improve error handling
- Fix documentation errors

### New Features

- New analysis methods
- Additional visualization options
- Performance improvements
- Support for additional data formats

### Documentation

- Improve existing documentation
- Add tutorials or examples
- Clarify confusing sections
- Translate documentation

### Code Quality

- Refactor for clarity or efficiency
- Add unit tests
- Improve error messages
- Remove deprecated code

## Development Setup

### Prerequisites

1. MATLAB (R2018b or later recommended)
2. Required toolboxes:
   - FieldTrip
   - Brainstorm
   - FreeSurfer
3. Git for version control

### Setting Up Development Environment

1. Clone the repository
2. Install required toolboxes
3. Add toolboxes to MATLAB path
4. Download sample data (if available)
5. Run tests to ensure everything works

### Testing Your Changes

Before submitting a PR:

1. Run the modified scripts with test data
2. Check for errors or warnings
3. Verify outputs are as expected
4. Test edge cases
5. Ensure documentation is accurate

## Pull Request Process

1. **PR Title**: Use a clear, descriptive title
   - Good: "Fix memory leak in PAC computation"
   - Bad: "Fixed bug"

2. **PR Description**: Include:
   - What changes were made
   - Why the changes were needed
   - How to test the changes
   - Any breaking changes
   - Related issue numbers (if applicable)

3. **Review Process**:
   - Maintainers will review your PR
   - Address any requested changes
   - Once approved, your PR will be merged

4. **Merge**:
   - PRs are typically merged via "Squash and merge"
   - Your contribution will be acknowledged

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Age, body size, disability
- Ethnicity, gender identity and expression
- Level of experience, education, socio-economic status
- Nationality, personal appearance, race, religion
- Sexual identity and orientation

### Our Standards

**Positive behaviors**:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards others

**Unacceptable behaviors**:
- Trolling, insulting/derogatory comments, personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of unacceptable behavior may be reported to the project maintainers. All complaints will be reviewed and investigated promptly and fairly.

## Questions?

If you have questions about contributing:
- Open an issue with the "question" label
- Contact the maintainers
- Check existing documentation

## Recognition

Contributors will be acknowledged in:
- The repository's contributor list
- Release notes (for significant contributions)
- Academic citations (for methodological contributions)

## License

By contributing to AD_PAC, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to AD_PAC! Your efforts help advance research in Alzheimer's Disease and neuroscience.
