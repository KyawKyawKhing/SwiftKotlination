package fr.jhandguy.swiftkotlination.features.topstories.viewmodel

import fr.jhandguy.swiftkotlination.features.story.model.Story
import fr.jhandguy.swiftkotlination.features.topstories.model.TopStoriesRepository
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.koin.dsl.module.module
import org.koin.standalone.StandAloneContext.closeKoin
import org.koin.standalone.StandAloneContext.startKoin
import org.koin.standalone.inject
import org.koin.test.KoinTest
import org.koin.test.declare

class TopStoriesViewModelUnitTest: KoinTest {

    val viewModel: TopStoriesViewModel by inject()

    @Before
    fun before(){
        startKoin(listOf(
                module {
                    factory { TopStoriesViewModel(get()) }
                }
        ))
    }

    @Test
    fun `top stories are fetched correctly`() {

        val stories = listOf(
                Story("section1", "subsection1", "title1", "abstract1", "url1", "byline1"),
                Story("section2", "subsection2", "title2", "abstract2", "url2", "byline2")
        )

        declare {
            factory { TopStoriesRepositoryMock(stories) as TopStoriesRepository }
        }

        viewModel
                .topStories
                .subscribe {
                    assertEquals(it, stories)
                }
    }

    @Test
    fun `error is thrown correctly`() {

        val error = Error("error message")

        declare {
            factory { TopStoriesRepositoryMock(error = error) as TopStoriesRepository }
        }

        viewModel
                .topStories
                .doOnError {
                    assertEquals(it, error)
                }
    }

    @After
    fun after(){
        closeKoin()
    }
}