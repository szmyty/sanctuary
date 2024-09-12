from opensource import licenses

def main():
    import os
    print(f"Host: {os.environ['PYTHONPYCACHEPREFIX']!r}")
    # [print(license.name) for license in licenses.all()]

if __name__ == "__main__":
    main()
