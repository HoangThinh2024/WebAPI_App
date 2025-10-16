from typing import Optional
import os
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from api_client import fetch_openings_list, fetch_opening, fetch_candidates
from data_processor import process_candidate_data
from api_client import fetch_candidate_detail, fetch_candidate_messages
# ...existing code...
