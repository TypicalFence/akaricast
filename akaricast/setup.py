from setuptools import setup

setup(
    name="akaricast",
    version="0.0.1",
    description="akaricast client",
    author="fence",
    license='GPL-3.0',
    packages=["akaricast"],
    entry_points={
        "console_scripts": [
            "akaricast = akaricast.cli:akaricast"
        ]
    },
)
