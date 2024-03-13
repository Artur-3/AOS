import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

public class project {
    private static HashMap<String, Integer> sumMap = new HashMap<>();
    private static HashMap<String, Integer> countMap = new HashMap<>();

    public static void main(String[] args) {
        readFile("stdin.txt");

        HashMap<String, Double> keyAverage = new HashMap<>();
        Set<String> keySet = sumMap.keySet();
        for (String key : keySet) {
            double value = (double) sumMap.get(key) / countMap.get(key);
            keyAverage.put(key, value);
        }

        List<Map.Entry<String, Double>> entryList = new ArrayList<>(keyAverage.entrySet());
        entryList.sort(Comparator.comparing(Map.Entry::getValue));

        List<String> keysList = new ArrayList<>();
        for (Map.Entry<String, Double> entry : entryList) {
            keysList.add(entry.getKey());
        }

        writeInFile("stdout.txt", keysList);

    }

    public static void readFile(String path) {
        try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
            String line;
            while ((line = reader.readLine()) != null) {
                StringTokenizer tokenizer = new StringTokenizer(line);
                String key = tokenizer.nextToken();
                if (tokenizer.hasMoreTokens()) {
                    int value = Integer.parseInt(tokenizer.nextToken());
                    sumMap.put(key, sumMap.getOrDefault(key, 0) + value);
                    countMap.put(key, countMap.getOrDefault(key, 0) + 1);
                } else {
                    break;
                }

            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void writeInFile(String path, List keysList) {
        try {
            Files.write(Paths.get("stdout.txt"), keysList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}