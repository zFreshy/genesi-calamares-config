import yaml
try:
    with open('etc/calamares/modules/netinstall.yaml', 'r', encoding='utf-8-sig') as f:
        data = yaml.safe_load(f)
        print("YAML is valid.")
except Exception as e:
    print(f"Error: {e}")