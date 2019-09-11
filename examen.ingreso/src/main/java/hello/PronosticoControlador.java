package hello;

import java.sql.*;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PronosticoControlador {
    //Declaracion de variables
    static Connection c;
    private String haySequia;
    private String hayLluvia;
    private String hayOptimas;
    private String dia;
    private String clima;

    @RequestMapping("/clima")
    public Pronostico greeting(@RequestParam(value="dia", defaultValue="1") String dia) throws SQLException {
        //El valor por default para el día es 1. Si se ingresa 0 se toma como el primero.
        if(dia.equals("0")) dia="1";
        //Inicializacion de variables
        clima="";
        hayLluvia="";
        haySequia="";
        hayOptimas="";

        //Se determina si el valor ingresado es Integer.
        //Si falla la conversion no es un valor valido.
        //Si la funcion devuelve falso el valor no es un numero entero
        try{
             if(!esInteger(dia))clima="Valor de dia invalido";
        }
        catch(Exception e){
            clima="Valor de dia invalido";
        }
        //
        //Si la variable fue asignada se devuelve el mensaje de error en la variable ingresada
        if (!clima.equals("")) return new Pronostico( dia,clima);

        //Si el numero de dias ingresado excede el rango permitido sale y se informa al usuario
        if(Integer.parseInt(dia) > 3550 )clima="Valor de dias excedido";
        if(Integer.parseInt(dia) < 0 )clima="Valor de dias invalido";
        if (!clima.equals("")) return new Pronostico( dia,clima);

        //Si el valor de dia ingresado es valido se consulta en el clima en la base de datos
        obtenerClima(dia);

        //Se construye el mensaje con los valores calculados con un SP en la base de datos.
        if(hayLluvia.equals("1"))clima="lluvia";
        if(haySequia.equals("1"))clima="sequia";
        if(hayOptimas.equals("1"))clima="optimas condiciones de presion atmosferica";
        //Si no se dan ninguna de las condiciones dadas en la consigna solo se sabe que no se dan las otras.
        // (No hay lluvia, ni sequias ni optimas condiciones de presion atmosferica)
        if(hayLluvia.equals("0") && haySequia.equals("0") && hayOptimas.equals("0"))clima="no hay lluvia";
        return new Pronostico( dia,clima);
    }

    public static boolean esInteger(String s) {
        return esInteger(s,10);
    }

    public static boolean esInteger(String s, int radix) {
        if(s.isEmpty()) return false;
        for(int i = 0; i < s.length(); i++) {
            if(i == 0 && s.charAt(i) == '-') {
                if(s.length() == 1) return false;
                else continue;
            }
            if(Character.digit(s.charAt(i),radix) < 0) return false;
        }
        return true;
    }

    public void obtenerClima(String dia ) throws SQLException {
        try {
           c = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

             c = DriverManager.getConnection( "jdbc:sqlserver://localhost;database=examen", "ML", "mercadopago@$2019");
            String query = "select Hay_lluvia,Hay_sequia,Hay_optimas_condiciones from pronostico where dia = "  +  dia;
            ps = c.prepareCall(query );
            ps.execute();
            rs = ps.getResultSet();

           while(rs.next()){
                hayLluvia = rs.getString(1);
                haySequia = rs.getString(2);
                hayOptimas = rs.getString(3);
            }

        }
        catch(Exception e){
            clima =e.toString();

        }

    }

}
/*
Referencias
Determinar si un número es entero
https://stackoverflow.com/questions/5439529/determine-if-a-string-is-an-integer-in-java
Determinar si un punto esta dentro de un triangulo
https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
*/