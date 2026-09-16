// SPDX-License-Identifier: GPL-3.0-only
#include <QDomDocument>
#include <QTest>

#include "news/NewsEntry.h"

class NewsEntryTest : public QObject {
    Q_OBJECT

   private slots:
    void articleLink_data()
    {
        QTest::addColumn<QString>("xml");
        QTest::addColumn<QString>("expected");
        QTest::newRow("github-release")
            << "<entry><id>tag:github.com,2008:Repository/123/v1</id>"
               "<link rel='alternate' type='text/html' href='https://example.com/releases/v1'/></entry>"
            << "https://example.com/releases/v1";
        QTest::newRow("default-alternate")
            << "<entry><id>urn:uuid:123</id><link href='https://example.com/news'/></entry>"
            << "https://example.com/news";
        QTest::newRow("skip-self-link")
            << "<entry><link rel='self' href='https://example.com/feed'/>"
               "<link rel='alternate' href='https://example.com/news'/></entry>"
            << "https://example.com/news";
        QTest::newRow("legacy-id") << "<entry><id>https://example.com/legacy</id></entry>"
                                   << "https://example.com/legacy";
    }

    void articleLink()
    {
        QFETCH(QString, xml);
        QFETCH(QString, expected);
        QDomDocument document;
        QVERIFY(document.setContent(xml));
        NewsEntry entry;
        QVERIFY(NewsEntry::fromXmlElement(document.documentElement(), &entry));
        QCOMPARE(entry.link, expected);
    }
};

QTEST_GUILESS_MAIN(NewsEntryTest)
#include "NewsEntry_test.moc"
