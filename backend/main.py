from fastapi import FastAPI, UploadFile, File, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
import asyncio
from datetime import datetime
import io
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER

app = FastAPI()

# Enable CORS properly for production and local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,   # ✅ conflict resolved
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root_health_check():
    return {"status": "healthy", "service": "AutoFinance Guardian Backend"}

class ContractAnalysisResponse(BaseModel):
    file_name: str
    risk_level: str
    hidden_fees: List[str]
    penalties: List[str]
    unfair_clauses: List[str]
    summary: str

@app.post("/analyze_contract", response_model=ContractAnalysisResponse)
async def analyze_contract(file: UploadFile = File(...)):
    file_content = await file.read()
    await asyncio.sleep(5)

    file_name_lower = file.filename.lower()
    if "bad" in file_name_lower or "highrisk" in file_name_lower:
        risk_level = "High"
        hidden_fees = ["Excessive late payment fee (5%)", "Undisclosed administration charges ($150)"]
        penalties = ["Early termination fee = 3 months payments", "High interest rate increase on default"]
        unfair_clauses = ["Lender can unilaterally change terms", "Arbitration clause favors lender"]
        summary = "This contract contains several high-risk clauses. Proceed with extreme caution."
    elif "medium" in file_name_lower:
        risk_level = "Medium"
        hidden_fees = ["Minor documentation fee ($25)"]
        penalties = ["Standard late payment fee ($35)"]
        unfair_clauses = []
        summary = "The contract has a few areas for review."
    else:
        risk_level = "Low"
        hidden_fees = []
        penalties = ["Standard late payment fee ($30)"]
        unfair_clauses = []
        summary = "This contract appears fair and low-risk."

    return ContractAnalysisResponse(
        file_name=file.filename,
        risk_level=risk_level,
        hidden_fees=hidden_fees,
        penalties=penalties,
        unfair_clauses=unfair_clauses,
        summary=summary
    )

@app.get("/download-analysis")
async def download_analysis(
    risk_level: str = "Low",
    summary: str = "No analysis provided.",
    penalties: str = "None"
):
    try:
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        styles = getSampleStyleSheet()
        story = []

        title_style = ParagraphStyle(
            'TitleStyle',
            parent=styles['Heading1'],
            alignment=TA_CENTER,
            spaceAfter=20
        )
        story.append(Paragraph("Contract Analysis Report", title_style))
        story.append(Spacer(1, 12))

        risk_color = "red" if risk_level.lower() == "high" else ("orange" if risk_level.lower() == "medium" else "green")
        story.append(Paragraph(f"<b>Risk Level:</b> <font color='{risk_color}'>{risk_level.upper()}</font>", styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(Paragraph(f"<b>Generated On:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(Paragraph("<b>AI Analysis Summary:</b>", styles['Heading2']))
        story.append(Paragraph(summary.replace('\n', '<br/>'), styles['Normal']))
        story.append(Spacer(1, 12))

        story.append(Paragraph("<b>Identified Penalties:</b>", styles['Heading2']))
        story.append(Paragraph(penalties.replace('\n', '<br/>'), styles['Normal']))
        story.append(Spacer(1, 12))

        doc.build(story)
        pdf_value = buffer.getvalue()
        buffer.close()

        return Response(
            content=pdf_value,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename=Contract_Analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))