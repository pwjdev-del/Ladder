import os
import requests
import json
import time

FIRECRAWL_API_KEY = os.environ.get("FIRECRAWL_API_KEY", "")
HEADERS = {
    "Authorization": f"Bearer {FIRECRAWL_API_KEY}",
    "Content-Type": "application/json"
}

# The schema we want Firecrawl to extract from the college admission pages
SCHEMA = {
    "type": "object",
    "properties": {
        "college_name": {"type": "string"},
        "early_action_deadline": {"type": "string", "description": "Date of Early Action deadline if exists, else None"},
        "regular_decision_deadline": {"type": "string", "description": "Date of Regular Decision deadline"},
        "testing_policy": {"type": "string", "description": "Is it test optional, test blind, or required?"},
        "transcript_requirement": {"type": "string", "description": "Does it require official transcripts, or self-reported (SSAR/Common App)?"},
        "application_platforms": {
            "type": "array",
            "items": {"type": "string"},
            "description": "e.g., Common App, Coalition, Institutional portal. Return an array of strings."
        }
    },
    "required": ["college_name", "regular_decision_deadline", "testing_policy", "transcript_requirement", "application_platforms"]
}

# A seed list of colleges mentioned in the brainstorming or popular in FL
COLLEGES = [
    # University of Florida
    "https://admissions.ufl.edu/apply/freshman/",
    # Florida State University
    "https://admissions.fsu.edu/freshman/apply/",
    # University of South Florida
    "https://www.usf.edu/admissions/freshman/index.aspx",
    # Rochester Institute of Technology (Mentioned in transcripts)
    "https://www.rit.edu/admissions/first-year",
    # University of Tampa (Mentioned in transcripts)
    "https://www.ut.edu/admissions/undergraduate-admissions",
    # Florida International University (Mentioned in transcripts)
    "https://admissions.fiu.edu/how-to-apply/freshman/index.html"
]

def extract_college_data(url):
    print(f"Starting extraction for: {url}")
    payload = {
        "url": url,
        "formats": ["extract"],
        "extract": {
            "schema": SCHEMA,
            "systemPrompt": "You are an expert college admissions counselor. Extract the core application requirements for first-year freshman applicants from the given webpage. Be precise."
        }
    }
    
    # We use scraping endpoint if it's a single page, but to capture all requirements it might be better 
    # to use crawl or just scrape the entry pipeline. We will use /v1/scrape to scrape the page directly with extraction.
    response = requests.post("https://api.firecrawl.dev/v1/scrape", headers=HEADERS, json=payload)
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success") and "extract" in data.get("data", {}):
            print(f"Successfully extracted data for {url}")
            return data["data"]["extract"]
        else:
            print(f"Extraction failed or returned empty for {url}: {data}")
            return None
    else:
        print(f"Error {response.status_code} for {url}: {response.text}")
        return None

def main():
    results = []
    
    for url in COLLEGES:
        extracted = extract_college_data(url)
        if extracted:
            results.append(extracted)
        # Be nice to the API
        time.sleep(2)
        
    output_file = "/Users/kathanpatel/Library/CloudStorage/GoogleDrive-patelkathan134@gmail.com/.shortcut-targets-by-id/1JI5nsUUu3Xe0VKLlfrogZ2xzskChkdGg/Ladder-Oloid (WIP)/Ideas/Research/college_requirements_db.json"
    
    with open(output_file, "w") as f:
        json.dump(results, f, indent=4)
        
    print(f"\nExtraction complete! Saved {len(results)} records to {output_file}")

if __name__ == "__main__":
    main()
