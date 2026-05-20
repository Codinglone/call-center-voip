"""
Shared configuration management utilities for SipForge.
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings


class BaseServiceConfig(BaseSettings):
    """Base configuration for all services."""
    
    log_level: str = "INFO"
    service_name: str = "voice-service"
    
    class Config:
        env_file = ".env"
        case_sensitive = False


class OrchestratorConfig(BaseServiceConfig):
    """Configuration for Chatbot Orchestrator service."""
    
    service_name: str = "orchestrator"
    redis_url: str = "redis://redis:6379"
    english_bot_url: str = "http://english-bot:8001"
    kinyarwanda_bot_url: str = "http://kinyarwanda-bot:8002"
    session_timeout: int = 300  # 5 minutes
    host: str = "0.0.0.0"
    port: int = 8000


class EnglishBotConfig(BaseServiceConfig):
    """Configuration for English Voice Chatbot service."""
    
    service_name: str = "english-bot"
    openai_api_key: str
    openai_model: str = "gpt-4"
    stt_service: str = "whisper"
    tts_service: str = "openai"
    host: str = "0.0.0.0"
    port: int = 8001
    response_timeout: int = 3  # seconds


class KinyarwandaBotConfig(BaseServiceConfig):
    """Configuration for Kinyarwanda Voice Chatbot service."""
    
    service_name: str = "kinyarwanda-bot"
    model_path: str = "/models"
    stt_model: str = "kinyarwanda-stt"
    llm_model: str = "kinyarwanda-llm"
    tts_model: str = "kinyarwanda-tts"
    host: str = "0.0.0.0"
    port: int = 8002
    response_timeout: int = 3  # seconds


def get_config(service_type: str) -> BaseServiceConfig:
    """
    Factory function to get configuration for a specific service.
    
    Args:
        service_type: Type of service ('orchestrator', 'english-bot', 'kinyarwanda-bot')
        
    Returns:
        Configuration object for the specified service
    """
    configs = {
        "orchestrator": OrchestratorConfig,
        "english-bot": EnglishBotConfig,
        "kinyarwanda-bot": KinyarwandaBotConfig,
    }
    
    config_class = configs.get(service_type)
    if not config_class:
        raise ValueError(f"Unknown service type: {service_type}")
    
    return config_class()
