"""Configuration loader for DipHunter"""
import yaml
import os
from pathlib import Path
from typing import Dict, Any

def load_config(config_path: str = None) -> Dict[str, Any]:
    """
    Load configuration from YAML file.
    """
    if config_path is None:
        # Look for config.yaml in project root
        project_root = Path(__file__).parent.parent.parent
        config_path = project_root / "config" / "config.yaml"
    
    if not os.path.exists(config_path):
        raise FileNotFoundError(
            f"Config file not found at {config_path}. "
        )
    
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    
    return config
