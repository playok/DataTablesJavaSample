<%@page import="java.util.Date"%>
<%@page import="oracle.jdbc.OracleDriver"%>
<%@page import="java.util.Enumeration"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.*"%>
<%
	System.out.println(new Date());

	Enumeration<String> param = request.getParameterNames();

	System.out.println("Parameters...");
	while (param.hasMoreElements()) {
		String key = param.nextElement();
		System.out.println("KEY : " + key + " VALUE [" + request.getParameter(key) + "]");
	}

	String length = request.getParameter("length");
	int displayStart = Integer.parseInt(request.getParameter("iDisplayStart"));
	int displayEnd = Integer.parseInt(request.getParameter("iDisplayLength"));
	String sEcho = request.getParameter("sEcho");

	System.out.println("grid parameter / 출력시작할 row index : " + displayStart);
	System.out.println("grid parameter / 출력종료할 row index : " + displayEnd);

	try {
		Class.forName("oracle.jdbc.OracleDriver");
	} catch (Exception e) {
		e.printStackTrace();
	}
	String table = "ajax";

	JSONObject result = new JSONObject();
	JSONArray array = new JSONArray();

	Connection conn = null;

	// 전체 건수
	int listCnt = 0;

	try {
		conn = DriverManager.getConnection("jdbc:oracle:thin:@12.0.0.1:1521:TBNAME", "ORA_ID", "ORA_PW");
		String sql = "SELECT count(*) totalCnt FROM " + table;
		PreparedStatement ps = conn.prepareStatement(sql);
		ResultSet rs = ps.executeQuery();
		if (rs.next()) {
			listCnt = rs.getInt("totalCnt");
		}
	} catch (Exception e) {
		e.printStackTrace();
	}

	PreparedStatement ps = null;
	ResultSet rs = null;
	try {
		StringBuffer SQL = new StringBuffer();
		SQL.append("SELECT \n");
		SQL.append("    * \n");
		SQL.append("FROM \n");
		SQL.append("    ( \n");
		SQL.append("      SELECT \n");
		SQL.append("         rownum rnum, \n");
		SQL.append("         a.* \n");
		SQL.append("      FROM  ").append(table).append(" a ) \n");
		SQL.append(" WHERE 1=1 \n");
		SQL.append(" AND rnum between ").append(displayStart).append(" and ").append(displayStart + displayEnd);

		System.out.println(SQL.toString());

		ps = conn.prepareStatement(SQL.toString());
		rs = ps.executeQuery();
		while (rs.next()) {
			JSONArray ja = new JSONArray();
			ja.put(rs.getString("rnum"));
			ja.put(rs.getString("engine"));
			ja.put(rs.getString("browser"));
			ja.put(rs.getString("platform"));
			ja.put(rs.getString("version"));
			ja.put(rs.getString("grade"));
			array.put(ja);
		}

		result.put("recordsTotal", listCnt);
		result.put("recordsFiltered", listCnt);
		result.put("draw", sEcho);
		result.put("data", array);

		response.setContentType("application/json");
		response.setHeader("Cache-Control", "no-store");
		out.print(result);
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		if ( rs!=null ) rs.close();
		if ( ps!=null ) ps.close();
		if ( conn!=null ) conn.close();
	}
%>
