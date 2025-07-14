Topics to cover

1. When to use `__` in filenames like `__index__.py` OR  `__main__.py`?
1. Why isn't "smarter" importing used, example
   ```python
   # This big library might only need to be used conditionally
   import cuda

   # Why wouldn't we use imports like
   if user.has.gpu:
     import cuda    # A library that uses Graphics GPU
   else:
     use_cpu = True
     import opencv  # A library that uses x86 CPU
   ```
1. Virtual Environments, Linters, package managers, and best practices
   1. Venv Compare/contrast: `uv`, `poetry`, `venv`, `pyenv`
   1. `ruff`, `black`, `flake8`, `pyright`, `pylint`
1. Improving performance; CPython versus other options (binary wheels, rust?)
1. Async options and libraries: `httpx`, `asyncio`, others?
   1. Future Python removing Global Interpreter Lock, how do libraries compare (`threading`, `multiprocessing`)
1. Python functions I'm not familiar with and when to use (`sorted`, others?)
1. Any datatype or other library I could use for the constant use case of 
not knowing how much RAM is available on a system and getting OOM errors?
   1. Preference for a smart library that could detect low RAM and martial data to disk
1. Python datatypes and when to use: `pandas`, `numpy`, `polars`
1. Argument parsing, (should I use `argparse`, or is there a newer native library)
1. Python "Function as a Service" alternatives to AWS Lambda (K8S OpenFAAS?)
1. Pydantic
1. Decorators
1. Use of type hinting (use of `:` in parameter, `->`)
   ```python
   def enhance_audio_quality(audio: np.ndarray, sr: int) -> np.ndarray:
      return True
   ```
   1. When (if ever) to strongly type, or is there a library?
      ```python
      a = 123
      b = int(456)  # Should we do this?
      ```
1. Vscode/IDE integration
   1. AI models and Code generation (PRs versus local suggestions)
   1. Could any AI models be run locally?
   1. Automate testing and linting
1. Automated testing: libraries for integration and end to end?
1. GUI options (`tkinter` still primary, `PyQt`?)
1. Pet project 1 million git commits in Python memory
   1. Random username/date commits
   1. Performant as possible by being all in memory until flushed to disk
      1. must export git compliant folder structure that can be commited to Github
