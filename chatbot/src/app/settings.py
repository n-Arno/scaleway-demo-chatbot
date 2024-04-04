import os
from typing import Dict
from llama_index.core.settings import Settings
from llama_index.llms.ollama import Ollama

def llm_config_from_env() -> Dict:
    from llama_index.core.constants import DEFAULT_TEMPERATURE

    model = os.getenv("MODEL")
    temperature = os.getenv("LLM_TEMPERATURE", DEFAULT_TEMPERATURE)

    config = {
        "model": model,
        "temperature": float(temperature),
        "request_timeout": 30.0,
        "base_url": "http://ollama:11434",
    }
    return config

def init_settings():
    llm_configs = llm_config_from_env()

    Settings.llm = Ollama(**llm_configs)
    Settings.embed_model = None
    Settings.chunk_size = int(os.getenv("CHUNK_SIZE", "1024"))
    Settings.chunk_overlap = int(os.getenv("CHUNK_OVERLAP", "20"))
