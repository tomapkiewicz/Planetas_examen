package hello;

public class Pronostico {

    private final String dia;
    private final String clima;

    public Pronostico(String dia, String clima) {
        this.dia = dia;
        this.clima = clima;
    }

    public String getDia() {
        return dia;
    }

    public String getClima() {
        return clima;
    }
}
