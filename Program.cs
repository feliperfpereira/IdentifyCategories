using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Threading;

namespace IdentifyCategories
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Please insert input data in DefaultDir/Sampleinput.txt !");

            var rules = Logic.loadCategory();
            var portfolio = Logic.GetPortifolio();
            var result = Logic.VerifyRisk(rules, portfolio);

            foreach (var item in result)
            {
                Console.WriteLine(item);
            }
        }

        #region Logica/Obtenção de dados
        public class Logic
        {
            public static List<CategoryRules> loadCategory()
            {
                List<CategoryRules> items = new List<CategoryRules>();
                string path = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), @"File\CategoryRules.json");
                using (StreamReader r = new StreamReader(path))
                {
                    string json = r.ReadToEnd();
                    items = JsonConvert.DeserializeObject<List<CategoryRules>>(json);
                }
                return items;
            }

            public static Portifolio GetPortifolio()
            {
                Portifolio portifolio = new Portifolio();
                portifolio.trades = new List<ITrade>();
                Stream stream = null;
                string line;
                string path = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), @"File\Sampleinput.txt");
                try
                {


                    stream = new FileStream(path, FileMode.OpenOrCreate);

                    // Open the text file using a stream reader.
                    using (var sr = new StreamReader(stream))
                    {
                        stream = null;
                        var lineNumber = 0;

                        while ((line = sr.ReadLine()) != null)
                        {

                            if (line.Length > 0)
                            {
                                switch (lineNumber)
                                {
                                    case 0:

                                        DateTime date;
                                        if (DateTime.TryParseExact(line, "MM/dd/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out date))
                                        {
                                            portifolio.ReferenceDate = date;
                                        }
                                        else
                                        {
                                            throw new InvalidOperationException();
                                        }
                                        break;
                                    case 1:
                                        int qtdTrades;
                                        if (int.TryParse(line, out qtdTrades))
                                        {
                                            portifolio.TradesCount = qtdTrades;
                                        }
                                        else
                                        {
                                            throw new InvalidOperationException();
                                        }

                                        break;
                                    default:

                                        var lineArr = line.Split(" ");

                                        if (lineArr.Length < 2)
                                        {
                                            throw new InvalidOperationException();
                                        }

                                        portifolio.trades.Add(
                                            new Trade(
                                                Convert.ToDouble(lineArr[0]),
                                                lineArr[1],
                                                DateTime.ParseExact(lineArr[2], "MM/dd/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None)
                                                )
                                            );
                                        break;
                                }

                            }

                            lineNumber++;
                        }

                    }
                }
                catch (IOException ex)
                {
                    Console.WriteLine("The file could not be read:");
                    Console.WriteLine(ex.Message);
                }
                finally
                {
                    if (stream != null)
                        stream.Dispose();
                }
                return portifolio;
            }

            public static List<string> VerifyRisk(List<CategoryRules> rules, Portifolio portifolio)
            {
                List<string> lst = new List<string>();

                foreach (var trade in portifolio.trades)
                {
                    bool find = false;
                    foreach (var rule in rules)
                    {
                        if (compareTradeRule(rule, trade, portifolio.ReferenceDate))
                        {
                            lst.Add(rule.CategoryName);
                            find = true;
                        }
                    }
                    if (!find)
                    {
                        lst.Add("UNKNOWN RISK");
                    }
                }

                return lst;
            }

            public static bool compareTradeRule(CategoryRules rule, ITrade trade, DateTime ReferenceDate)
            {
                if (trade.ClientSector == rule.Client)
                {
                    switch (rule.Conditional)
                    {
                        case ConditionalRule.LessThan:
                            if (trade.Value < rule.Value)
                            {
                                return true;
                            }
                            break;
                        case ConditionalRule.GreaterThen:
                            if (trade.Value > rule.Value)
                            {
                                return true;
                            }
                            break;
                        case ConditionalRule.DelayInDays:
                            if ((ReferenceDate - trade.NextPaymentDate).TotalDays > rule.Value)
                            {
                                return true;
                            }
                            break;
                        default:
                            break;
                    }
                }

                return false;
            }

        }
        #endregion

        #region Classes/Interfaces
        public class CategoryRules
        {
            public string CategoryName { get; set; }
            public string Client { get; set; }
            public double Value { get; set; }
            public ConditionalRule Conditional { get; set; }
        }

        public enum ConditionalRule
        {
            LessThan,
            GreaterThen,
            DelayInDays
        }

        public interface ITrade
        {
            double Value { get; }
            string ClientSector { get; }
            DateTime NextPaymentDate { get; }
        }

        public class Trade : ITrade
        {
            public Trade(
                 double value,
                 string clientSector,
                 DateTime nextPaymentDate
                 )
            {
                Value = value;
                ClientSector = clientSector;
                NextPaymentDate = nextPaymentDate;

            }
            public double Value { get; private set; }
            public string ClientSector { get; private set; }
            public string Risk { get; private set; }
            public DateTime NextPaymentDate { get; private set; }
        }

        public class Portifolio
        {
            public DateTime ReferenceDate { get; set; }
            public int TradesCount { get; set; }
            public List<ITrade> trades { get; set; }

        }
        #endregion
    }
}
