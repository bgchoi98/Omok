<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="rank.Rank" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rank</title>

<style>
body {
    font-family: Arial, sans-serif;
    display: flex;
    justify-content: center;
    align-items: flex-start;
    min-height: 100vh;
    margin: 0;
    padding: 40px 0;
    background-color: #f0f0f0;
    box-sizing: border-box;
}

.rank-container {
    width: 650px;
    padding: 40px;
    border-radius: 10px;
    background-color: #ffffff;
    text-align: center;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.rank-container h1 {
    margin-bottom: 30px;
    color: #333;
}

.rank-table {
    width: 100%;
    border-collapse: collapse;
}

.rank-table thead {
    background-color: #5aaad1;
    color: white;
}

.rank-table th {
    padding: 12px;
    font-weight: bold;
}

.rank-table td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
    color: #555;
}

.rank-table tbody tr:hover {
    background-color: #f2f8fc;
}

.rank-table tbody tr:nth-child(1) {
    font-weight: bold;
    color: #d4af37;
}
.rank-table tbody tr:nth-child(2) {
    font-weight: bold;
    color: #9e9e9e;
}
.rank-table tbody tr:nth-child(3) {
    font-weight: bold;
    color: #cd7f32;
}
</style>
</head>

<body>

<%
    List<Rank> ranks = (List<Rank>) request.getAttribute("ranks");
    if (ranks == null) {
        ranks = java.util.Collections.emptyList(); //null이면 0으로 
    }

    int limit = Math.min(10, ranks.size());	//상위 10개만
%>

<div class="rank-container">
    <h1>🏆 랭킹 TOP10</h1>

    <table class="rank-table">
        <thead>
            <tr>
                <th>순위</th>
                <th>닉네임</th>
                <th>승</th>
                <th>패</th>
                <th>승률 (%)</th>
            </tr>
        </thead>
        <tbody>
        <%
            for (int i = 0; i < limit; i++) {
                Rank r = ranks.get(i);
        %>
            <tr>
                <td><%= i + 1 %></td>
                <td><%= r.getNickName() %></td>
                <td><%= r.getWin() %></td>
                <td><%= r.getLose() %></td>
                <td><%= r.getRate() %> %</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>

</body>
</html>
