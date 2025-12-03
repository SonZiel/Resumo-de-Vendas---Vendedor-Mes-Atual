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

