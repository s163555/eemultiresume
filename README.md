# CurVeResume Project
This project builds LaTeX-based resumes using either `latexmk` or `lualatex` through CMake. The build system is designed to handle different resume "flavors" (e.g., `hw`, `sw`, `ic`) and supports out-of-source builds for cleanliness.

---

## Prerequisites
To build this project, you need the following tools installed:

- **CMake** (version 3.10 or later)
- **TeXLive** or similar LaTeX distribution with the following packages:
  - `latexmk`
  - `biber` (optional for bibliography processing)
  - `lualatex`
  - `texlive-latex-recommended`, `texlive-latex-extra`, `texlive-fonts-recommended`
- A working `git` installation

---

## Cloning the Repository
To get started, clone the repository using `git`:

```bash
git clone https://github.com/s163555/eemultiresume.git
cd eemultiresume
```

## Building the Project
### Configure the Project
Use CMake to configure the build system. Perform the following steps in the terminal:
```
cmake -S . -B build -DCOMPILER=latexmk
```
- Replace latexmk with lualatex if you prefer to use lualatex directly.
- This command configures the build system into a separate build/ directory to keep the source directory clean.

### Build the LaTeX Documents
Run the following command to build all flavors:
```
cmake --build build
```
This will:
- Generate PDF outputs for all the specified "flavors" (e.g., hw, sw, ic).
- Place the output PDFs into the build/output directory.

#### Build a single target
Run the following command to build a single flavor:
```
cmake --build build --target flavor
```

### Cleaning Auxiliary Files
To clean up generated auxiliary files (logs, temporary outputs, etc.), run:
```
cmake --build build --target clean_aux
```

### Cleaning All Generated Files
To clean all generated files, including the final PDFs, use:
```
cmake --build build --target clean_all
```

### Rebuilding the Project
To perform a full clean and rebuild:
```
cmake --build build --target rebuild
```

## Output
After a successful build, the resulting PDF files will be located in: `build/output/`
Each "flavor" of the resume will have its own PDF, such as:
- cv-hw.pdf (for hardware-focused resume)
- cv-sw.pdf (for software-focused resume)
- cv-ic.pdf (for integrated circuits-focused resume)

### Preview

# Contributing
Contributions are welcome! Please follow these steps:
- Fork the repository.
- Create a new branch: git checkout -b feature/your-feature-name.
- Make your changes and commit them.
- Push to the branch: git push origin feature/your-feature-name.
- Open a Pull Request.

# License
This project is licensed under the GPLv2 License. See the [LICENSE](LICENSE) file for details.

# Acknowledgments
Thanks to the LaTeX and CMake communities for providing powerful tools to streamline document generation.
Special thanks to John Collins for providing feedback about Latexmk and Make integration.
