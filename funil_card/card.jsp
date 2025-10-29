<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Funil de Vendas - Moderno</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f4f6f9;
      color: #333;
      text-align: center;
      margin: 0;
      padding: 20px;
    }

    .container {
      max-width: 700px;
      margin: auto;
      background: #fff;
      padding: 20px;
      border-radius: 15px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    h2 {
      margin-bottom: 5px;
      color: #1e293b;
    }

    .info {
      color: #475569;
      font-size: 15px;
      margin-bottom: 20px;
    }

    .funnel {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
    }

    .stage {
      position: relative;
      width: 100%;
      height: 60px;
      clip-path: polygon(0 0, 100% 0, 80% 100%, 20% 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: bold;
      transition: transform 0.3s;
      cursor: pointer;
    }

    .stage:hover {
      transform: scale(1.05);
    }

    .orcamentos { background: #3b82f6; }
    .pedidos { background: #1e293b; }
    .vendas { background: #22c55e; }
    .devolucoes { background: #f97316; }
    .comissao { background: #0db2be; }

    .label {
      position: absolute;
      bottom: -20px;
      font-size: 14px;
      color: #334155;
    }

    .legend {
      display: flex;
      justify-content: center;
      gap: 15px;
      margin-top: 20px;
    }

    .legend div {
      display: flex;
      align-items: center;
      gap: 5px;
    }

    .color-box {
      width: 15px;
      height: 15px;
      border-radius: 3px;
    }
    .meta-progress {
      margin-top: 25px;
      background: #f9fafb;
      border-radius: 12px;
      padding: 15px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
      text-align: center;
      font-family: 'Segoe UI', sans-serif;
    }

    .meta-info {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 8px;
      font-size: 14px;
      color: #111827;
      margin-bottom: 8px;
    }

    .meta-icon {
      font-size: 20px;
    }

    .motivacao {
      font-size: 15px;
      font-weight: 600;
      color: #047857;
    }

  </style>
  <snk:load/> <!-- essa tag deve ficar nesta posição -->
</head>
<body>
<snk:query var="vendas">
WITH 
VENDEDOR AS (
    SELECT 
        U.CODVEND,
        U.CODUSU,
        U.CODVEND || ' - ' || INITCAP(V.APELIDO) AS NOME_VENDEDOR
    FROM TSIUSU U
    INNER JOIN TGFVEN V ON V.CODVEND = U.CODVEND
    WHERE U.CODUSU = ${userID}
),

META AS (
    SELECT 
        SUM(NVL(MET.PREVREC, 0)) AS META,
        MET.CODVEND
    FROM TGFMET MET
    WHERE MET.CODMETA = 1
    AND TRUNC(MET.DTREF, 'MM') = TRUNC(SYSDATE, 'MM')
    AND MET.CODVEND = (SELECT CODVEND FROM VENDEDOR)
    GROUP BY MET.CODVEND
),

ORCAMENTOS AS (
    SELECT 
        SUM(CAB.VLRNOTA) AS TOTAL,
        CAB.CODVEND
    FROM TGFCAB CAB
    WHERE CAB.CODTIPOPER IN (999, 1000, 1005, 1056, 1300, 1303, 1002)
    AND TO_CHAR(CAB.DTNEG, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY')
    AND CAB.CODVEND = (SELECT CODVEND FROM VENDEDOR)
    GROUP BY CAB.CODVEND
),

PEDIDOS AS (
    SELECT 
        SUM(CAB.VLRNOTA) AS TOTAL,
        CAB.CODVEND
    FROM TGFCAB CAB
    WHERE CAB.CODTIPOPER IN (1001, 1003, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1017, 1018, 1051, 1052, 1055, 1057)
    AND TO_CHAR(CAB.DTNEG, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY')
    AND CAB.CODVEND = (SELECT CODVEND FROM VENDEDOR)
    GROUP BY CAB.CODVEND
),

VENDAS AS (
    SELECT 
         SUM(
            CASE 
                WHEN CAB.CODTIPOPER IN (
                    SELECT CODTIPOPER FROM TGFTOP WHERE ATUALCOM = 'C' AND TIPMOV = 'V' AND CAB.CIF_FOB = 'F'
                ) THEN CAB.VLRNOTA
                WHEN CAB.CODTIPOPER IN (
                        SELECT CODTIPOPER FROM TGFTOP WHERE ATUALCOM = 'C' AND TIPMOV = 'V' AND CIF_FOB IS NULL
                    ) THEN CAB.VLRNOTA
                WHEN CAB.CODTIPOPER IN (
                    SELECT CODTIPOPER FROM TGFTOP WHERE ATUALCOM = 'C' AND TIPMOV = 'V' AND CAB.CIF_FOB = 'C'
                ) THEN CAB.VLRNOTA - NVL(CAB.VLRFRETE,0)
                WHEN CAB.CODTIPOPER IN (
                    SELECT CODTIPOPER FROM TGFTOP WHERE ATUALCOM = 'C' AND TIPMOV = 'D'
                ) THEN -CAB.VLRNOTA
                ELSE 0
            END
        ) AS TOTAL,
        CAB.CODVEND
    FROM TGFCAB CAB
    WHERE TO_CHAR(CAB.DTNEG, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY')
    AND CAB.CODVEND = (SELECT CODVEND FROM VENDEDOR)
    GROUP BY CAB.CODVEND
),

DEVOLUCOES AS (
    SELECT 
        SUM(CAB.VLRNOTA) AS TOTAL,
        CAB.CODVEND
    FROM TGFCAB CAB
    WHERE CAB.CODTIPOPER IN (1201, 1202, 1203, 3202)
    AND TO_CHAR(CAB.DTNEG, 'MM/YYYY') = TO_CHAR(SYSDATE, 'MM/YYYY')
    AND CAB.CODVEND = (SELECT CODVEND FROM VENDEDOR)
    GROUP BY CAB.CODVEND
)

SELECT 
    V.NOME_VENDEDOR AS VENDEDOR,
    NVL(M.META, 0) AS META,
    NVL(O.TOTAL, 0) AS ORCAMENTOS,
    NVL(P.TOTAL, 0) AS PEDIDOS,
    NVL(VS.TOTAL, 0) AS VENDAS,
    NVL(D.TOTAL, 0) AS DEVOLUCOES,
    ROUND(NVL(VS.TOTAL, 0) * 0.01, 2) AS COMISSAO,
    ROUND((NVL(VS.TOTAL, 0) / NULLIF(M.META, 0)) * 100, 2) AS PERCEN_META,
    CASE
        WHEN (NVL(VS.TOTAL, 0) / NULLIF(M.META, 0)) * 100 >= 100 THEN 'Parabéns! Meta atingida!'
        WHEN (NVL(VS.TOTAL, 0) / NULLIF(M.META, 0)) * 100 >= 75 THEN 'Excelente! Falta pouco pra meta!'
        WHEN (NVL(VS.TOTAL, 0) / NULLIF(M.META, 0)) * 100 >= 50 THEN 'Bom desempenho, mantenha o ritmo!'
        ELSE 'Continue firme! Você está no caminho certo!'
    END AS MENSAGEM_MOTIVACIONAL
    FROM VENDEDOR V
    LEFT JOIN META M ON M.CODVEND = V.CODVEND
    LEFT JOIN ORCAMENTOS O ON O.CODVEND = V.CODVEND
    LEFT JOIN PEDIDOS P ON P.CODVEND = V.CODVEND
    LEFT JOIN VENDAS VS ON VS.CODVEND = V.CODVEND
    LEFT JOIN DEVOLUCOES D ON D.CODVEND = V.CODVEND
  </snk:query>

    <c:forEach var="row" items="${vendas.rows}">
        <div class="container">
            <h2>Resumo de Vendas - Mês Atual</h2>
            <p class="info">Vendedor: <c:out value="${row.VENDEDOR}"/> || <b>Meta: R$ <fmt:formatNumber value="${row.META}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></p></b>

            <div class="funnel">
            <div class="stage orcamentos">Orçamentos - R$ <fmt:formatNumber value="${row.ORCAMENTOS}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></div>
            <div class="stage pedidos">Pedidos - R$ <fmt:formatNumber value="${row.PEDIDOS}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></div>
            <div class="stage vendas">Vendas Líquidas - R$ <fmt:formatNumber value="${row.VENDAS}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></div>
            <div class="stage devolucoes">Devoluções - R$ <fmt:formatNumber value="${row.DEVOLUCOES}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></div>
            <div class="stage comissao">Comissão - R$ <fmt:formatNumber value="${row.COMISSAO}" type= "number" minFractionDigits="2" maxFractionDigits="2"/></div>
            </div>
    
            <!-- 🔹 Progresso da Meta e Mensagem Motivacional -->
          <div class="meta-progress">
            <div class="meta-info">
              <div class="meta-text">
                <strong>Progresso:</strong> <c:out value="${row.PERCEN_META}"/> %
              </div>
            </div>
            <div class="motivacao">
              <em><c:out value="${row.MENSAGEM_MOTIVACIONAL}"/></em>
            </div>
          </div>
    </c:forEach>
    
        <script>
    // Interatividade: destaque suave ao passar o mouse (sem alert)
    document.querySelectorAll('.stage').forEach(stage => {
        stage.addEventListener('mouseenter', () => {
            stage.style.transform = 'scale(1.03)';
            stage.style.boxShadow = '0 6px 20px rgba(0, 0, 0, 0.2)';
            stage.style.transition = 'all 0.25s ease';
        });
        stage.addEventListener('mouseleave', () => {
            stage.style.transform = 'scale(1)';
            stage.style.boxShadow = '0 4px 10px rgba(0, 0, 0, 0.1)';
        });
    });
</script>

</body>
</html>
